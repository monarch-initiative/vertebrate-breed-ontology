---
name: merge-terms
description: Merge two VBO terms that represent the same breed — obsolete one term with replaced_by the other, move all its synonyms, xrefs, parents, relationships, annotations, sources, contributors and term trackers to the kept term, and rewire every term that pointed at it. Use when a curator asks to merge, deduplicate or "obsolete X in favour of Y" in vbo-edit.obo. Not for obsoleting a term without a replacement.
argument-hint: [VBO ID] [VBO ID] [optional: GitHub issue URL]
---

# Merge two VBO terms

Two terms are merged when they represent the same breed. One term (**VBO1**) is obsoleted and replaced by
the term that is kept (**VBO2**). Everything on VBO1 moves to VBO2.

- **Scope:** merging only (obsolete *with* `replaced_by`). Plain obsoletion is not covered.
- **Edit location:** `src/ontology/vbo-edit.obo` only. VBO no longer uses ROBOT templates or Google Sheets;
  ignore references to them (including in `docs/VBO-editor-documents/merge_obsolete_editor.md`).
- **Helper script:** `.claude/skills/merge-terms/scripts/vbo_merge.py` (`inspect`, `apply`, `verify`).
  Always run it from the repository root. It does the mechanical edits; you do the checks and the talking.

## Step 1 — Collect inputs (ask for anything missing)

| Input | Required | Notes |
|---|---|---|
| The two VBO IDs | yes | |
| Which term is kept | no | If not given, apply the keep-rule (Step 3) |
| GitHub issue URL (term tracker) | yes | `https://github.com/monarch-initiative/vertebrate-breed-ontology/issues/N` — **ask** |
| ORCID of the person doing the merge | yes | Added as contributor on VBO2 — **ask** if not given; never guess |
| Evidence that they are the same breed | no | Only if the curator gives it → becomes the comment on VBO1 |
| Git branch | yes | Use the branch the curator names; otherwise `issue-{number}`. Never edit on `master` |

## Step 2 — Branch

- `git fetch` and make sure local `master` is up to date with `origin/master` (fast-forward only).
- If the requested branch already exists, check it has no commits beyond `master`
  (`git log master..<branch>`) before switching to it; do not recreate it. If it has other commits, ask.
- Tell the user which branch they are on.

## Step 3 — Inspect

```bash
python3 .claude/skills/merge-terms/scripts/vbo_merge.py inspect VBO:AAAAAAA VBO:BBBBBBB
```

This prints both stanzas, every reference to each term, the keep-rule result and the conflicts.

**Keep-rule** (only when the curator did not say which to keep), applied in order:
1. Keep the term that has **OMIA as a source** (`http://omia.org` / `https://omia.org` anywhere on the term).
   VBO has no `xref: OMIA:` lines. Both or neither → next rule.
2. Keep the term with **more xrefs**.
3. Keep the term with **more information** (more lines).
4. Still a tie, or you have doubts → **ask**.

Show the curator the two stanzas (or a summary), the keep-rule reasoning, the number of terms that will be
rewired, and the planned result. **Wait for confirmation before editing.**
Mention it when VBO1 is the DAD-IS transboundary name with national-population children (they will be
moved under VBO2 and keep their own labels).

**Conflicts → always ask the curator; never resolve them yourself.** The script flags:
- either term already obsolete, a DAD-IS national breed population (`VBO:0300020`), or with `intersection_of`
- different species suffix or different `NCBITaxon` parent
- the same synonym text with a different scope on the two terms
- a `def` on VBO1; a `comment` on both terms (needs combined text)
- different breed-level parents (e.g. Cattle Dog vs Mountain Dog)
- different `breed_code`, `hasdomesticationstatus` or `origindescription` values
- VBO1 `is_a` VBO2 (or the reverse) — that link is dropped
- any tag the procedure does not handle

Once the curator has decided, re-run `apply` with `--accept-conflicts` (and `--kept-comment` if needed),
then fix anything they decided differently from the default by hand.

## Step 4 — Apply

```bash
python3 .claude/skills/merge-terms/scripts/vbo_merge.py apply \
  --obsolete VBO1 --keep VBO2 \
  --issue https://github.com/monarch-initiative/vertebrate-breed-ontology/issues/N \
  --orcid https://orcid.org/XXXX-XXXX-XXXX-XXXX \
  [--obsolete-comment "Evidence text"] [--kept-comment "Combined comment"] [--accept-conflicts]
```

What it does (these are the curator's rules — if you edit by hand, follow them exactly):

**On VBO2 (kept).** Nothing is ever duplicated: if VBO2 already has the same annotation, VBO1's sources
are added to VBO2's existing line.

| From VBO1 | On VBO2 |
|---|---|
| `name` | `synonym: "<VBO1 label, exactly, incl. (Species)>" EXACT [] {source="VBO1"}` |
| most_common_name synonym | Plain `EXACT` synonym — VBO2 keeps its own most common name unless the curator says otherwise |
| other synonyms | Same text and scope, with sources |
| `xref`, `subset` | Transferred with sources |
| `is_a` (SubClassOf) | Transferred with sources; `is_a: VBO2` dropped (no self-loop) |
| `relationship` (`VBO:0300019` has foundation stock, `VBO:0300020`) | Transferred with sources |
| `property_value` (recognition status, breed code, origin, domestication…) | Transferred with sources |
| `dcterms:contributor`, `dcterms:source` | Union |
| `IAO:0000233` term trackers | Union, **plus** the merge issue |
| `comment` | Moved if VBO2 has none; if both have one → curator-provided text |
| — | **plus** `dcterms:contributor <merger ORCID>` |

**On VBO1 (obsoleted)** — only these lines remain:

```obo
[Term]
id: VBO1
name: obsolete <original label, incl. (Species)>
comment: <only if the curator gave evidence>
property_value: IAO:0000231 "terms merged" xsd:string
property_value: IAO:0000233 "<VBO1's existing trackers + the merge issue>" xsd:anyURI
is_obsolete: true
replaced_by: VBO2
```

All other content — including contributors and sources — is removed from VBO1 (it now lives on VBO2).
**No comment by default.**

**Rewiring.** Every other term's `is_a: VBO1`, `relationship: <rel> VBO1`, `replaced_by: VBO1` and
`consider: VBO1` now point to VBO2, with the trailing `! label` updated. Sources are kept. If that term
already points to VBO2, the sources are merged instead of adding a duplicate line. The script prints how
many references it rewired and lists any other mention of VBO1 it did not change. Review that list.

Lines are inserted in the file's tag order and alphabetically within a tag; existing lines are not
reordered. New sources are appended to existing source lists.

## Step 5 — Verify

```bash
python3 .claude/skills/merge-terms/scripts/vbo_merge.py verify \
  --obsolete VBO1 --keep VBO2 --issue <URL> --orcid <ORCID>      # compares with HEAD
git diff --stat                                                    # only the expected stanzas
```

`verify` checks: VBO1 has only the allowed lines; every line of VBO1 (before) is on VBO2 with all its
sources; nothing on VBO2 was lost; the label synonym is present; VBO2's most common name is unchanged;
no duplicate lines or self-references; the tracker and contributor are on VBO2; nothing still references
VBO1 except the label-synonym source.

Then run the CI QC. `run.sh` uses `docker run -ti`, which fails without a terminal ("the input device is
not a TTY"). Pipe a copy without `-t` (do not edit `run.sh`). It takes more than 10 minutes, so run it in
the background:

```bash
cd src/ontology && sed 's/--rm -ti /--rm -i /' run.sh | \
  sh -s make ROBOT_ENV='ROBOT_JAVA_ARGS=-Xmx6G' test IMP=false PAT=false MIR=false </dev/null
```

It must end with `Finished running all tests successfully.` and `ERROR: 0`. `duplicate_exact_synonym`
warnings on the kept term are expected when DAD-IS national populations share the name.

## Step 6 — Report and prepare the PR

- Tell the curator: VBO1 → VBO2, which keep-rule decided it, what moved (from the `apply` output), how many
  terms were rewired, conflicts and how they were resolved, and the verify and QC results.
- Prepare the PR description (title `Merge <VBO1 label> into <VBO2 label>`, `Addresses #N`, the
  above details, ending with the Claude Code attribution line).
- **Do not commit, push or open the PR unless the curator asks**; the curator usually commits.

## Merging more than two terms

Merge one pair at a time (VBO1 → VBO2, then VBO3 → VBO2), and verify after each merge.

## Worked example (2026-10-19, issue #242)

`VBO:0000090` Aberdeen-Angus (Cattle) → `VBO:0000104` Angus (Cattle). Both have OMIA as a source; Angus
has 1 xref vs 0, so Angus is kept. Moved: `"Aberdeen-Angus"` (was most_common_name → EXACT), label synonym
`"Aberdeen-Angus (Cattle)"`, `"German Angus"`, one extra `is_a NCBITaxon:9913` source, 2 ISBN sources,
tracker #120; #242 added on both. 66 `is_a` children rewired (65 DAD-IS national populations). Verify
OK; `make test` passed.
