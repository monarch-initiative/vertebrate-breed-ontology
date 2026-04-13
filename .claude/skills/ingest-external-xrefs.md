---
description: Ingest external breed cross-references into VBO. Use when adding xrefs from an external source (e.g., VeNom, DAD-IS) to the Vertebrate Breed Ontology — validates proposed xrefs, detects duplicates, handles "(unspecified)" qualifiers, detects near-matches, and generates validated ROBOT templates.
---

# Ingest External Cross-References into VBO

You are helping curate the Vertebrate Breed Ontology (VBO). This skill guides the
full workflow for ingesting breed cross-references from an external source into VBO.

## Prerequisites

The user must provide:
- **A changes TSV file** with columns: `action`, `VBO_ID`, `VBO_name`, `VeNom_term_name` (or equivalent external name), `VeNom_ID` (or equivalent external ID), `VeNom_subset` (species/breed category).
  - `action` is either `add_xref` (add xref to existing VBO term) or `new_term` (propose a new VBO term).
- **The external source URL** (e.g., `https://venomcoding.org/venom-codes/`)
- **The GitHub issue URL** tracking this work
- **The contributor ORCID** — must be one of the approved ORCIDs (see Validation below)

## Workflow

### Step 1: Create a task directory

Create a task directory under `src/ontology/tasks/<source_name_xref>/` with subdirectories:
- `data/` — for input data and output reports

### Step 2: Validate proposed xrefs

Write and run a validation script (see `src/ontology/tasks/venom_xref/validate_xrefs.py` as a reference) that:

**A) For `add_xref` entries** (xrefs to existing VBO terms):
1. Parse `src/ontology/vbo-edit.obo` to load all VBO terms, their names, EXACT synonyms, and NCBITaxon parents.
2. Strip species qualifiers from VBO names (e.g., "(Horse)", "(Cat)", "(Dog)", "(Rabbit)", "(Ass)") for comparison.
3. Compare VBO name (stripped) vs external name — case-insensitive.
4. If names don't match, check EXACT synonyms of the VBO term.
5. Classify each entry as: `exact_match`, `case_diff_only`, `synonym_match`, or `MANUAL_REVIEW`.
6. Write a TSV report to `data/validation_report.tsv`.

**B) For `new_term` entries** (proposed new VBO terms):
1. Build case-insensitive indices of all existing VBO term names and synonyms.
2. For each proposed new term, check if the external name already exists in VBO (species-aware matching using NCBITaxon).
3. Detect `(unspecified)` qualifiers: strip them and re-check for matches.
4. Detect **"breed, country" terms** — VBO terms whose name follows the pattern `Name, Country (Species)` (e.g., "Beveren, United States of America (Rabbit)"). These are DAD-IS-sourced entries. **Do not treat matches against breed, country terms as duplicates unless the external source is DAD-IS.** Classify these as `COUNTRY_BREED_ONLY`.
5. Classify each entry as: `no_duplicate`, `COUNTRY_BREED_ONLY`, `POTENTIAL_DUPLICATE`, or `UNSPECIFIED_MATCH`.
6. Write a TSV report to `data/new_term_duplicates_report.tsv`.
7. For entries classified as `POTENTIAL_DUPLICATE`, generate a separate `data/potential_duplicates_review.tsv` with existing VBO term names resolved for manual review.

**C) Near-match detection** — **ALWAYS run this step and present results to the user for review before proceeding.**

Some `new_term` entries may be near-matches to existing VBO terms due to naming variants. These should be detected and presented to the user. If confirmed, change them from `new_term` to `add_xref` in the changes file.

Common near-match patterns by species:

**Cat breeds — hair length variants:**
- `Long-Haired` / `Long Hair` / `Longhair` are equivalent (e.g., VeNom "Oriental Long Hair" = VBO "Oriental Longhair")
- `Short-Haired` / `Short Hair` / `Shorthair` are equivalent (e.g., VeNom "British Short Hair" = VBO "British Shorthair")
- Also check `Colourpoint` vs `Colorpoint` spelling variants

**Horse breeds — Horse/Pony suffix variants:**
- Some VBO terms include "Horse" or "Pony" in the name but the external source omits it (e.g., VeNom "Fell" = VBO "Fell Pony", VeNom "Australian Stock" = VBO "Australian Stock Horse")
- Try adding "Horse" and "Pony" to the external name and checking for matches
- Also try removing "Horse" and "Pony" from the external name
- Skip matches that only hit breed, country terms (DAD-IS entries)

**Detection approach:**
1. For cat breeds: normalize all hair-length variants to a canonical form and re-check
2. For horse breeds: generate variants with/without "Horse"/"Pony" suffixes and re-check
3. Present ALL near-matches to the user in a table for review
4. Only add confirmed matches as `add_xref` entries — do not auto-add without user approval
5. Remove confirmed entries from the `new_term` list to avoid creating duplicates

**Species-aware matching** — map the external source's breed categories to NCBITaxon IDs. Common mappings:

| External category | NCBITaxon |
|---|---|
| Rabbit breed | NCBITaxon:9986 |
| Horse breed | NCBITaxon:9796 |
| Feline breed | NCBITaxon:9685 |
| Canine breed | NCBITaxon:9615 |
| Donkey breed | NCBITaxon:9793 |
| Cattle breed | NCBITaxon:9913 |
| Sheep breed | NCBITaxon:9940 |
| Goat breed | NCBITaxon:9925 |
| Pig breed | NCBITaxon:9823 |
| Chicken breed | NCBITaxon:9031 |

For hybrids (e.g., Mule, Hinny), use multiple NCBITaxon parents.

### Step 3: Generate TWO ROBOT templates

Generate two separate ROBOT template TSVs — one for new terms, one for xrefs to existing terms.

#### Template 1: New terms (`src/ontology/tmp/merge_template.tsv`)

Using the duplicates report, generate a ROBOT template for adding new breed terms (see `src/ontology/tasks/venom_xref/generate_robot_template.py` as a reference):

- **Include** entries with status `no_duplicate`, `UNSPECIFIED_MATCH`, and `COUNTRY_BREED_ONLY`.
- **Exclude** entries with status `POTENTIAL_DUPLICATE` — these need manual curation.
- **Exclude** entries that were converted to `add_xref` via near-match detection.
- The template must follow the column format defined in the existing `merge_template.tsv` (75 columns with ROBOT template strings in row 2).

**Required annotations per row:**

| Column | ROBOT string | Value |
|---|---|---|
| ID | `ID` | The VBO ID (e.g., `VBO:0018011`) |
| LABEL | `LABEL` | Breed name with species qualifier (e.g., `Altex (Rabbit)`) |
| parent_ID | `SC %` | NCBITaxon ID for the species |
| parent_ID | `SC %` | `VBO:0400000` (Vertebrate breed) |
| most_common_name | `A oboInOwl:hasExactSynonym` | The external source's breed name |
| synonym_type | `>AI oboInOwl:hasSynonymType` | `http://purl.obolibrary.org/obo/vbo#most_common_name` |
| source | various `>AT oboInOwl:source` | The external source URL |
| xref | `A oboInOwl:hasDbXref SPLIT=\|` | External ID (e.g., `VeNom:18420`) |
| contributors | `AI dc:contributor SPLIT=\|` | Contributor ORCID |
| source_for_breed | `AT dc:source^^xsd:anyURI SPLIT=\|` | The external source URL |

#### Template 2: Xrefs to existing terms (`src/ontology/tmp/xref_template.tsv`)

Generate a ROBOT template for adding cross-references, synonyms, and most_common_name annotations to existing VBO terms:

| Column | ROBOT string | Value |
|---|---|---|
| ID | `ID` | The existing VBO ID |
| vbo_name | *(empty)* | The existing VBO name — **for manual review only**, not ingested by ROBOT |
| xref | `A oboInOwl:hasDbXref SPLIT=\|` | External ID (e.g., `VeNom:79023`) |
| source_for_xref | `>AT oboInOwl:source^^xsd:anyURI SPLIT=\|` | The external source URL |
| source_for_xref | `>A oboInOwl:source SPLIT=\|` | The external source URL |
| most_common_name | `A oboInOwl:hasExactSynonym` | The external name as most_common_name synonym (see rules below) |
| synonym_type_most_common_name | `>AI oboInOwl:hasSynonymType` | `http://purl.obolibrary.org/obo/vbo#most_common_name` |
| source_for_most_common_name | `>AT oboInOwl:source^^xsd:anyURI SPLIT=\|` | The external source URL |
| synonym | `A oboInOwl:hasExactSynonym` | The external name as an exact synonym (see rules below) |
| source_for_synonym | `>AT oboInOwl:source^^xsd:anyURI SPLIT=\|` | The external source URL |
| source_for_synonym | `>A oboInOwl:source SPLIT=\|` | The external source URL |
| source_for_breed | `AT dc:source^^xsd:anyURI SPLIT=\|` | The external source URL |
| contributors | `AI dc:contributor SPLIT=\|` | Contributor ORCID |

**Synonym rules for the xref template:**
- **`exact_match` entries** (VBO name without species qualifier exactly matches external name): populate `most_common_name`, `synonym_type_most_common_name`, and `source_for_most_common_name` columns. Leave the synonym columns empty.
- **All other match types** (`synonym_match`, `case_diff_only`, `manual_review` / near-matches): add the external name as an exact synonym in the `synonym` column with the external source URL as provenance. Leave the most_common_name columns empty.

This includes ALL `add_xref` entries (both original and those converted from `new_term` via near-match detection).

**Rules for labels (new terms template):**
- Labels with `(unspecified)` in the external name: strip `(unspecified)` from both the label and the `most_common_name` synonym. Add the original name WITH `(unspecified)` as a separate exact synonym (in `synonym_1` column).
- Accented characters (e.g., Crème, Española, Cão) must be preserved as proper Unicode — do not transliterate.
- Hybrid breeds (Mule, Hinny) get a third parent column with the second NCBITaxon.

**Rules for breed, country terms:**
- VBO contains many DAD-IS-sourced terms with the pattern `Name, Country (Species)` (e.g., "Beveren, United States of America (Rabbit)"). These are country-specific breed records.
- When an external source (other than DAD-IS) proposes a generic breed name like "Beveren" and it only matches these country-specific terms, it is **not a true duplicate**. The generic breed term should still be added to VBO.
- Only DAD-IS xrefs should map to breed, country terms. All other external sources should get their own generic breed entries.
- The validation script detects this pattern automatically: if all matched VBO terms have a comma in their name (after stripping the species qualifier), the entry is classified as `COUNTRY_BREED_ONLY` and included in the template.

### Step 4: Validate the ROBOT templates

Run the template validation script on both templates:

```bash
python3 src/ontology/scripts/validate_robot_template.py src/ontology/tmp/merge_template.tsv
python3 src/ontology/scripts/validate_robot_template.py src/ontology/tmp/xref_template.tsv
```

This checks:

1. **NCBITaxon IDs** — every taxon used as a parent must already exist in VBO (listed in `src/ontology/imports/ncbitaxon_terms.txt` or referenced in `vbo-edit.obo`). If a taxon is missing, **ask the user before adding it** to `imports/ncbitaxon_terms.txt`. Do not add it without confirmation. The import must be regenerated after any additions.

2. **Approved ORCIDs** — every ORCID in contributor or source annotation columns must be one of:
   - `https://orcid.org/0000-0002-5002-8648` (Katie Mullen)
   - `https://orcid.org/0000-0002-4142-7153` (Sabrina Toro)

   Any other ORCID is flagged as an error. **Ask the user if the ORCID is okay to use** before adding it to the approved list. If approved, add it to the `APPROVED_ORCIDS` set in `src/ontology/scripts/validate_robot_template.py`.

3. **Structure** — VBO IDs match `VBO:\d{7}`, labels are non-empty.

4. **No (unspecified) in labels** — any label still containing `(unspecified)` is an error.

5. **Accented characters** — flagged as warnings for manual review (not errors).

Fix all errors before proceeding. Warnings are informational.

### Step 5: Coverage check

Verify that every breed term from the external source is accounted for — either already in VBO, in the xref template, or in the merge template. Report any gaps.

**Intentional exclusions:** Crossbreed terms (e.g., those ending in " X" like "Thoroughbred X", "Arab X") are out of scope for VBO and should be excluded from the coverage check. Note any such exclusions in the task.md file.

### Step 6: Review and handoff

Present the user with:
- Summary counts (exact matches, synonym matches, near-matches, duplicates, unspecified matches, country-breed-only)
- Any entries requiring manual review
- Validation results (errors/warnings) for both templates
- The paths to both generated templates

The user will review and decide whether to proceed with merging the templates using ROBOT.

## Key files

| File | Purpose |
|---|---|
| `src/ontology/vbo-edit.obo` | The source OBO file for VBO |
| `src/ontology/imports/ncbitaxon_terms.txt` | NCBITaxon IDs imported into VBO |
| `src/ontology/tmp/merge_template.tsv` | Output ROBOT template for new terms |
| `src/ontology/tmp/xref_template.tsv` | Output ROBOT template for xrefs to existing terms |
| `src/ontology/scripts/validate_robot_template.py` | Template validation script |
| `src/ontology/tasks/venom_xref/` | Reference implementation for VeNom xrefs |
