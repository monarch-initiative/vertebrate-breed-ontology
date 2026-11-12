#!/usr/bin/env python3
"""Merge two VBO terms in vbo-edit.obo (obsolete one, replace it by the other).

Subcommands (run from the repository root):

  inspect VBO1 VBO2
      Show both stanzas, every reference to them, which term the keep-rule
      selects, and any conflicts. Makes no changes.

  apply --obsolete VBO1 --keep VBO2 --issue URL --orcid URL
        [--obsolete-comment TEXT] [--kept-comment TEXT] [--accept-conflicts]
      Move all content of VBO1 onto VBO2, obsolete VBO1 with replaced_by VBO2,
      and rewire every other term pointing at VBO1. Refuses to run if there are
      conflicts, unless --accept-conflicts is given (after a curator decided).

  verify --obsolete VBO1 --keep VBO2 --issue URL --orcid URL [--before GITREF]
      Check the result against the file at GITREF (default HEAD).

Common option: --obo PATH (default src/ontology/vbo-edit.obo).
"""
import argparse
import re
import subprocess
import sys

DEFAULT_OBO = "src/ontology/vbo-edit.obo"
TERMS_MERGED = 'property_value: IAO:0000231 "terms merged" xsd:string'
TRACKER = "IAO:0000233"
CONTRIBUTOR = "dcterms:contributor"
ISSUE_RE = re.compile(r"^https://github\.com/monarch-initiative/vertebrate-breed-ontology/issues/\d+$")
ORCID_RE = re.compile(r"^https://orcid\.org/\d{4}-\d{4}-\d{4}-\d{3}[\dX]$")
ID_RE = re.compile(r"^VBO:\d{7}$")

TAG_ORDER = ["id", "is_anonymous", "name", "namespace", "alt_id", "def", "comment", "subset",
             "synonym", "xref", "is_a", "intersection_of", "union_of", "disjoint_from",
             "relationship", "property_value", "is_obsolete", "replaced_by", "consider",
             "created_by", "creation_date"]
# Tags this script knows how to transfer. Anything else on VBO1 is a conflict.
TRANSFERABLE = {"id", "name", "def", "comment", "subset", "synonym", "xref", "is_a",
                "relationship", "property_value"}
# property_value properties where a different value on the two terms needs a curator decision
SINGLE_VALUED = {"hasdomesticationstatus", "origindescription"}
REVIEW_VALUED = {"breed_code"}


# --------------------------------------------------------------------------- parsing

class Line:
    """One tag-value line: `tag: core {qualifiers} ! comment`."""

    def __init__(self, raw):
        self.raw = raw
        self.tag, _, rest = raw.partition(": ")
        self.core, self.quals, self.comment = split_value(rest)

    def render(self):
        s = f"{self.tag}: {self.core}"
        if self.quals:
            s += " {" + ", ".join(f'{k}="{v}"' for k, v in self.quals) + "}"
        if self.comment is not None:
            s += f" ! {self.comment}"
        return s

    def add_quals(self, quals):
        for q in quals:
            if q not in self.quals:
                self.quals.append(q)


def split_value(rest):
    """Split a tag value into (core, qualifier list, trailing ! comment)."""
    in_q = esc = False
    brace = bang = None
    for i, c in enumerate(rest):
        if esc:
            esc = False
            continue
        if c == "\\":
            esc = True
        elif c == '"':
            in_q = not in_q
        elif not in_q and c == "{" and brace is None and rest[i - 1:i] == " ":
            brace = i
        elif not in_q and c == "!" and rest[i - 1:i] == " " and (brace is None or rest.rfind("}", 0, i) > brace):
            bang = i
            break
    end = bang - 1 if bang is not None else len(rest)
    comment = rest[bang + 2:] if bang is not None else None
    quals = []
    if brace is not None:
        qtxt = rest[brace + 1:rest.rfind("}", 0, end + 1)]
        quals = re.findall(r'(\w+)="((?:[^"\\]|\\.)*)"', qtxt)
        core = rest[:brace - 1]
    else:
        core = rest[:end].rstrip()
    return core, [tuple(q) for q in quals], comment


SYN_RE = re.compile(r'^"((?:[^"\\]|\\.)*)" (\w+)(?: ([\w:]+))? \[(.*)\]$')


def syn_parts(core):
    m = SYN_RE.match(core)
    if not m:
        raise ValueError(f"cannot parse synonym: {core}")
    return m.group(1), m.group(2), m.group(3), m.group(4)


def key_of(line):
    """Identity used to detect 'the same annotation' on two terms."""
    t = line.tag
    if t == "synonym":
        text, scope, _type, _x = syn_parts(line.core)
        return ("synonym", text)            # scope compared separately (conflict)
    if t in ("xref", "is_a", "subset"):
        return (t, line.core.split()[0])
    if t == "relationship":
        rel, target = line.core.split()[:2]
        return (t, rel, target)
    if t == "property_value":
        return (t, line.core)
    return (t, line.core)


class Obo:
    def __init__(self, text):
        self.chunks = text.split("\n\n")       # header + stanzas, separated by blank lines

    def text(self):
        return "\n\n".join(self.chunks)

    def find(self, tid):
        for i, c in enumerate(self.chunks):
            if c.startswith("[Term]\n") and f"\nid: {tid}\n" in c + "\n":
                return i
        return None

    def set(self, i, lines):
        """Replace chunk i, preserving any trailing newline(s) (end of file)."""
        old = self.chunks[i]
        tail = old[len(old.rstrip("\n")):]
        self.chunks[i] = "\n".join(lines) + tail


def stanza_lines(chunk):
    """[Term] chunk -> list[Line] (without the header line)."""
    return [Line(l) for l in chunk.split("\n")[1:] if l.strip()]


def label_of(lines):
    return next(l.core for l in lines if l.tag == "name")


def species_of(label):
    m = re.search(r"\(([^()]+)\)$", label)
    return m.group(1) if m else None


def count(lines, pred):
    return sum(1 for l in lines if pred(l))


# --------------------------------------------------------------------------- analysis

def keep_rule(a_id, a, b_id, b):
    """Return (kept_id or None, explanation) following the curator rule."""
    def omia(ls):
        return any("omia.org" in l.raw for l in ls)
    steps = []
    oa, ob = omia(a), omia(b)
    steps.append(f"OMIA as source: {a_id}={'yes' if oa else 'no'}, {b_id}={'yes' if ob else 'no'}")
    if oa != ob:
        return (a_id if oa else b_id), steps
    xa, xb = count(a, lambda l: l.tag == "xref"), count(b, lambda l: l.tag == "xref")
    steps.append(f"xrefs: {a_id}={xa}, {b_id}={xb}")
    if xa != xb:
        return (a_id if xa > xb else b_id), steps
    ia, ib = len(a), len(b)
    steps.append(f"information (number of lines): {a_id}={ia}, {b_id}={ib}")
    if ia != ib:
        return (a_id if ia > ib else b_id), steps
    steps.append("tie -> ask the curator")
    return None, steps


def conflicts(old_id, old, keep_id, keep):
    """Things a curator must decide before (or while) merging."""
    out = []
    lo, lk = label_of(old), label_of(keep)
    for tid, ls in ((old_id, old), (keep_id, keep)):
        if any(l.tag == "is_obsolete" for l in ls):
            out.append(f"{tid} is already obsolete")
        if any(l.tag == "relationship" and l.core.startswith("VBO:0300020 ") for l in ls):
            out.append(f"{tid} is a DAD-IS national breed population (relationship VBO:0300020)")
        if any(l.tag == "intersection_of" for l in ls):
            out.append(f"{tid} has a logical definition (intersection_of)")
    if species_of(lo) != species_of(lk):
        out.append(f"different species suffix: {lo!r} vs {lk!r}")
    tax_o = {l.core.split()[0] for l in old if l.tag == "is_a" and l.core.startswith("NCBITaxon:")}
    tax_k = {l.core.split()[0] for l in keep if l.tag == "is_a" and l.core.startswith("NCBITaxon:")}
    if tax_o and tax_k and tax_o != tax_k:
        out.append(f"different NCBITaxon parents: {sorted(tax_o)} vs {sorted(tax_k)}")
    for l in old:
        if l.tag not in TRANSFERABLE:
            out.append(f"{old_id} has a tag this procedure does not handle: {l.raw}")
    if any(l.tag == "def" for l in old):
        out.append(f"{old_id} has a definition: decide what to do with it")
    if any(l.tag == "comment" for l in old) and any(l.tag == "comment" for l in keep):
        out.append("both terms have a comment: provide the combined text with --kept-comment")
    keep_syn = {}
    for l in keep:
        if l.tag == "synonym":
            text, scope, _t, _x = syn_parts(l.core)
            keep_syn.setdefault(text, set()).add(scope)
    for l in old:
        if l.tag == "synonym":
            text, scope, _t, _x = syn_parts(l.core)
            if text in keep_syn and scope not in keep_syn[text]:
                out.append(f'synonym "{text}" is {scope} on {old_id} but {"/".join(sorted(keep_syn[text]))} on {keep_id}')
    for prop in sorted(SINGLE_VALUED | REVIEW_VALUED):
        vo = {l.core for l in old if l.tag == "property_value" and l.core.split()[0] == prop}
        vk = {l.core for l in keep if l.tag == "property_value" and l.core.split()[0] == prop}
        if vo and vk and vo != vk:
            out.append(f"different {prop}: {sorted(vo)} on {old_id} vs {sorted(vk)} on {keep_id}")
    generic = {"VBO:0400000", old_id, keep_id}
    par_o = {l.core.split()[0] for l in old if l.tag == "is_a" and l.core.startswith("VBO:")} - generic
    par_k = {l.core.split()[0] for l in keep if l.tag == "is_a" and l.core.startswith("VBO:")} - generic
    if par_o and par_k and par_o != par_k:
        out.append(f"different breed-level parents: {sorted(par_o)} on {old_id} vs {sorted(par_k)} on {keep_id} "
                   f"(by default both would be kept on {keep_id})")
    for l in old:
        if l.tag == "is_a" and l.core.split()[0] == keep_id:
            out.append(f"{old_id} is_a {keep_id} (the parent link is dropped, not transferred)")
        if l.tag == "relationship" and l.core.split()[1] == keep_id:
            out.append(f"{old_id} has {l.core.split()[0]} {keep_id} (would point to itself, dropped)")
    for l in keep:
        if l.tag in ("is_a", "relationship") and old_id in l.core.split()[:2]:
            out.append(f"{keep_id} points to {old_id}: {l.raw} (dropped)")
    return out


def references(obo, tid, skip=()):
    """(chunk index, line) for every line outside `skip` stanzas mentioning tid."""
    pat = re.compile(re.escape(tid) + r"(?!\d)")
    refs = []
    for i, c in enumerate(obo.chunks):
        if i in skip:
            continue
        for l in c.split("\n"):
            if pat.search(l):
                refs.append((i, l))
    return refs


# --------------------------------------------------------------------------- editing

def sort_key(line):
    if line.tag == "synonym":
        return syn_parts(line.core)[0].lower()
    return line.core.lower()


def insert_sorted(lines, new):
    """Insert `new` in canonical tag order, alphabetically (case-insensitive) within its tag,
    without reordering existing lines."""
    rank = TAG_ORDER.index(new.tag) if new.tag in TAG_ORDER else len(TAG_ORDER)
    pos = len(lines)
    for i, l in enumerate(lines):
        r = TAG_ORDER.index(l.tag) if l.tag in TAG_ORDER else len(TAG_ORDER)
        if r > rank or (r == rank and sort_key(l) > sort_key(new)):
            pos = i
            break
    lines.insert(pos, new)


TRANSFER_LOG = []


def merge_line(keep_lines, new, keep_id):
    """Add `new` to keep_lines, merging qualifiers into an existing equivalent line."""
    k = key_of(new)
    for l in keep_lines:
        if l.tag != new.tag or key_of(l) != k:
            continue
        if new.tag == "synonym" and syn_parts(l.core)[1] != syn_parts(new.core)[1]:
            continue                       # different scope: kept separate (reported as conflict)
        added = [q for q in new.quals if q not in l.quals]
        l.add_quals(new.quals)
        if added:
            TRANSFER_LOG.append("  sources added to: " + l.render())
        return
    insert_sorted(keep_lines, new)
    TRANSFER_LOG.append("  new line:          " + new.render())


def do_merge(obo, old_id, keep_id, issue, orcid, obsolete_comment=None, kept_comment=None):
    io, ik = obo.find(old_id), obo.find(keep_id)
    old, keep = stanza_lines(obo.chunks[io]), stanza_lines(obo.chunks[ik])
    old_label, keep_label = label_of(old), label_of(keep)
    report = []

    # 1. label of VBO1 -> EXACT synonym on VBO2, sourced to VBO1
    merge_line(keep, Line(f'synonym: "{old_label}" EXACT [] {{source="{old_id}"}}'), keep_id)

    # 2. everything else from VBO1
    old_comment = None
    for l in old:
        if l.tag in ("id", "name"):
            continue
        if l.tag == "comment":
            old_comment = l.core
            continue
        if l.tag == "property_value" and l.core.split()[0] == "IAO:0000231":
            continue
        if l.tag in ("is_a", "relationship"):
            target = l.core.split()[0 if l.tag == "is_a" else 1]
            if target in (keep_id, old_id):
                continue
        if l.tag == "synonym":
            text, scope, typ, xr = syn_parts(l.core)
            if typ == "most_common_name":       # kept term keeps its own most common name
                l = Line(l.raw.replace(f'" {scope} most_common_name [', f'" {scope} [', 1))
        merge_line(keep, l, keep_id)
    keep = [l for l in keep if not (l.tag in ("is_a", "relationship")
                                     and old_id in l.core.split()[:2])]

    # 3. comment handling
    if kept_comment is not None:
        keep = [l for l in keep if l.tag != "comment"]
        insert_sorted(keep, Line(f"comment: {kept_comment}"))
    elif old_comment is not None and not any(l.tag == "comment" for l in keep):
        insert_sorted(keep, Line(f"comment: {old_comment}"))

    # 4. tracker + contributor on VBO2
    merge_line(keep, Line(f'property_value: {TRACKER} "{issue}" xsd:anyURI'), keep_id)
    merge_line(keep, Line(f"property_value: {CONTRIBUTOR} {orcid}"), keep_id)

    # 5. obsolete stanza
    trackers = [l.raw for l in old if l.tag == "property_value" and l.core.startswith(TRACKER + " ")]
    new_tracker = f'property_value: {TRACKER} "{issue}" xsd:anyURI'
    if new_tracker not in trackers:
        trackers.append(new_tracker)
    trackers.sort(key=lambda s: Line(s).core.lower())
    obs = ["[Term]", f"id: {old_id}", f"name: obsolete {old_label}"]
    if obsolete_comment:
        obs.append(f"comment: {obsolete_comment}")
    obs += [TERMS_MERGED] + trackers + ["is_obsolete: true", f"replaced_by: {keep_id}"]

    obo.set(ik, ["[Term]"] + [l.render() for l in keep])
    obo.set(io, obs)

    # 6. rewire other stanzas pointing at VBO1
    rewired, other = 0, []
    pat = re.compile(re.escape(old_id) + r"(?!\d)")
    for i, c in enumerate(obo.chunks):
        if i in (io, ik) or not pat.search(c):
            continue
        head, *rest = c.rstrip("\n").split("\n")
        ls = [Line(l) for l in rest]
        out, changed = [], False
        for l in ls:
            if l.tag == "is_a" and l.core.split()[0] == old_id:
                nl = Line(l.raw)
                nl.core = keep_id
                nl.comment = keep_label
                existing = [x for x in out + ls if x is not l and x.tag == "is_a" and x.core.split()[0] == keep_id]
                if existing:
                    existing[0].add_quals(nl.quals)
                else:
                    out.append(nl)
                changed = True
                rewired += 1
            elif l.tag == "relationship" and l.core.split()[1] == old_id:
                rel = l.core.split()[0]
                nl = Line(l.raw)
                nl.core = f"{rel} {keep_id}"
                nl.comment = re.sub(re.escape(old_label) + "$", keep_label, l.comment or "") or None
                existing = [x for x in out + ls if x is not l and x.tag == "relationship"
                            and x.core.split()[:2] == [rel, keep_id]]
                if existing:
                    existing[0].add_quals(nl.quals)
                else:
                    out.append(nl)
                changed = True
                rewired += 1
            elif l.tag in ("replaced_by", "consider") and l.core == old_id:
                nl = Line(l.raw)
                nl.core = keep_id
                out.append(nl)
                changed = True
                rewired += 1
            else:
                if pat.search(l.raw) and not re.search(r'source="' + re.escape(old_id) + '"', l.raw):
                    other.append(l.raw)
                out.append(l)
        if changed:
            obo.set(i, [head] + [l.render() for l in out])
    report.append(f"changes on {keep_id} ({keep_label}):")
    report += TRANSFER_LOG
    report.append(f"rewired {rewired} reference(s) from other terms to {keep_id}")
    if other:
        report.append("OTHER mentions of the obsolete ID left unchanged (review):")
        report += ["  " + o for o in other]
    return report


# --------------------------------------------------------------------------- verification

def verify(before, after, old_id, keep_id, issue, orcid):
    errs, notes = [], []
    bo, bk = stanza_lines(before.chunks[before.find(old_id)]), stanza_lines(before.chunks[before.find(keep_id)])
    ao, ak = stanza_lines(after.chunks[after.find(old_id)]), stanza_lines(after.chunks[after.find(keep_id)])
    old_label = label_of(bo)

    allowed = {"id", "name", "comment", "is_obsolete", "replaced_by"}
    for l in ao:
        if l.tag == "property_value" and l.core.split()[0] in ("IAO:0000231", TRACKER):
            continue
        if l.tag not in allowed:
            errs.append(f"obsolete term still has: {l.raw}")
    want = {f"name: obsolete {old_label}", TERMS_MERGED, "is_obsolete: true", f"replaced_by: {keep_id}",
            f'property_value: {TRACKER} "{issue}" xsd:anyURI'}
    for w in want:
        if w not in [l.raw for l in ao]:
            errs.append(f"obsolete term is missing: {w}")

    def present(l):
        for x in ak:
            if x.tag == l.tag and key_of(x) == key_of(l) and all(q in x.quals for q in l.quals):
                if l.tag != "synonym" or syn_parts(x.core)[1] == syn_parts(l.core)[1]:
                    return True
        return False
    for l in bo:
        if l.tag in ("id", "name", "comment") or l.raw == TERMS_MERGED:
            continue
        if l.tag in ("is_a", "relationship") and keep_id in l.core.split()[:2]:
            continue
        if not present(l):
            errs.append(f"not transferred to {keep_id}: {l.raw}")
    for l in bk:
        if l.tag in ("is_a", "relationship") and old_id in l.core.split()[:2]:
            continue
        if not present(l) and l.tag != "comment":
            errs.append(f"lost from {keep_id}: {l.raw}")
    if not any(l.tag == "synonym" and syn_parts(l.core)[:2] == (old_label, "EXACT")
               and ("source", old_id) in l.quals for l in ak):
        errs.append(f'missing label synonym "{old_label}" EXACT {{source="{old_id}"}}')
    mcn = {syn_parts(l.core)[0] for l in ak if l.tag == "synonym" and syn_parts(l.core)[2] == "most_common_name"}
    mcn_before = {syn_parts(l.core)[0] for l in bk if l.tag == "synonym" and syn_parts(l.core)[2] == "most_common_name"}
    if mcn != mcn_before:
        errs.append(f"most_common_name changed on {keep_id}: {mcn_before} -> {mcn}")
    raws = [l.raw for l in ak]
    if len(raws) != len(set(raws)):
        errs.append(f"duplicate lines on {keep_id}")
    for l in ak:
        if l.tag in ("is_a", "relationship") and keep_id in l.core.split()[:2]:
            errs.append(f"{keep_id} points to itself: {l.raw}")
    if f'property_value: {TRACKER} "{issue}" xsd:anyURI' not in raws:
        errs.append(f"{keep_id} is missing the tracker {issue}")
    if f"property_value: {CONTRIBUTOR} {orcid}" not in raws:
        errs.append(f"{keep_id} is missing the contributor {orcid}")

    io = after.find(old_id)
    for i, l in references(after, old_id, skip={io}):
        if f'source="{old_id}"' in l:
            continue
        errs.append(f"still references {old_id}: {l}")
    n_before = len([1 for i, l in references(before, old_id, skip={before.find(old_id)})])
    notes.append(f"references to {old_id} outside its stanza: before={n_before}, "
                 f"after={len(references(after, old_id, skip={io}))} (only the label-synonym source should remain)")
    return errs, notes


# --------------------------------------------------------------------------- CLI

def load(path):
    with open(path, encoding="utf-8") as f:
        return Obo(f.read())


def check_ids(*ids):
    for i in ids:
        if not ID_RE.match(i):
            sys.exit(f"not a VBO ID: {i}")


def cmd_inspect(a):
    check_ids(a.term1, a.term2)
    obo = load(a.obo)
    idx = {t: obo.find(t) for t in (a.term1, a.term2)}
    for t, i in idx.items():
        if i is None:
            sys.exit(f"{t} not found in {a.obo}")
    s = {t: stanza_lines(obo.chunks[i]) for t, i in idx.items()}
    for t, i in idx.items():
        print(f"===== {t}\n{obo.chunks[i]}\n")
    for t, i in idx.items():
        refs = references(obo, t, skip={i})
        print(f"===== {len(refs)} reference(s) to {t} from other terms")
        for _, l in refs[:15]:
            print("  " + l)
        if len(refs) > 15:
            print(f"  ... {len(refs) - 15} more")
    kept, steps = keep_rule(a.term1, s[a.term1], a.term2, s[a.term2])
    print("\n===== keep-rule (OMIA source -> most xrefs -> most information)")
    for st in steps:
        print("  " + st)
    print(f"  => keep {kept}" if kept else "  => UNCLEAR: ask the curator")
    if kept:
        old = a.term2 if kept == a.term1 else a.term1
        c = conflicts(old, s[old], kept, s[kept])
        print(f"\n===== conflicts if {old} is merged into {kept}: {len(c)}")
        for x in c:
            print("  - " + x)


def cmd_apply(a):
    check_ids(a.obsolete, a.keep)
    if not ISSUE_RE.match(a.issue):
        sys.exit(f"issue must be a VBO GitHub issue URL: {a.issue}")
    if not ORCID_RE.match(a.orcid):
        sys.exit(f"orcid must look like https://orcid.org/0000-0000-0000-0000: {a.orcid}")
    obo = load(a.obo)
    io, ik = obo.find(a.obsolete), obo.find(a.keep)
    if io is None or ik is None:
        sys.exit("term not found")
    c = conflicts(a.obsolete, stanza_lines(obo.chunks[io]), a.keep, stanza_lines(obo.chunks[ik]))
    if c and not a.accept_conflicts:
        print("CONFLICTS - ask the curator, then re-run with --accept-conflicts:")
        for x in c:
            print("  - " + x)
        sys.exit(2)
    for line in do_merge(obo, a.obsolete, a.keep, a.issue, a.orcid, a.obsolete_comment, a.kept_comment):
        print(line)
    with open(a.obo, "w", encoding="utf-8") as f:
        f.write(obo.text())
    print(f"merged {a.obsolete} into {a.keep} in {a.obo}")


def cmd_verify(a):
    check_ids(a.obsolete, a.keep)
    before_txt = subprocess.run(["git", "show", f"{a.before}:{a.obo}"], capture_output=True,
                                text=True, check=True).stdout
    errs, notes = verify(Obo(before_txt), load(a.obo), a.obsolete, a.keep, a.issue, a.orcid)
    for n in notes:
        print(n)
    if errs:
        print(f"FAILED ({len(errs)}):")
        for e in errs:
            print("  - " + e)
        sys.exit(1)
    print("OK: all checks passed")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--obo", default=DEFAULT_OBO)
    sub = p.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("inspect")
    s.add_argument("term1")
    s.add_argument("term2")
    s.set_defaults(fn=cmd_inspect)
    for name, fn in (("apply", cmd_apply), ("verify", cmd_verify)):
        s = sub.add_parser(name)
        s.add_argument("--obsolete", required=True)
        s.add_argument("--keep", required=True)
        s.add_argument("--issue", required=True)
        s.add_argument("--orcid", required=True)
        if name == "apply":
            s.add_argument("--obsolete-comment")
            s.add_argument("--kept-comment")
            s.add_argument("--accept-conflicts", action="store_true")
        else:
            s.add_argument("--before", default="HEAD")
        s.set_defaults(fn=fn)
    a = p.parse_args()
    a.fn(a)


if __name__ == "__main__":
    main()
