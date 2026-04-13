# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The Vertebrate Breed Ontology (VBO) is an OBO Foundry ontology providing standardized vocabulary for vertebrate breed names across 38 species and 15,000+ breeds. It is maintained by the Monarch Initiative and draws primarily from FAO's DAD-IS (Domestic Animal Diversity Information System). The main editing file is `src/ontology/vbo-edit.obo` (~298K lines, OBO format).

## Build System

VBO uses the **Ontology Development Kit (ODK) v1.6** with Docker. All make commands should be run from `src/ontology/` using the Docker wrapper:

```bash
# Run QC tests (same as CI)
cd src/ontology && sh run.sh make test

# Run QC tests without Docker (matches CI exactly)
cd src/ontology && make ROBOT_ENV='ROBOT_JAVA_ARGS=-Xmx6G' test IMP=false PAT=false MIR=false

# Full release pipeline
cd src/ontology && sh run.sh make prepare_release IMP=false -B

# Refresh external imports (ncbitaxon, ro, wikidata, omo, cob)
cd src/ontology && sh run.sh make refresh-imports

# Sync ROBOT templates from Google Sheets
cd src/ontology && sh run.sh make sync_google_sheets

# Rebuild component files from downloaded templates
cd src/ontology && sh run.sh make recreate-components
```

The Docker image is `obolibrary/odkfull:v1.6` with 16G Java heap (`-Xmx16G`).

## Key Architecture

### Data Pipeline
Google Sheets (ROBOT templates) → TSV files in `src/ontology/components/` → OBO edit file → release artifacts (OWL, OBO, JSON)

### Important Files
- **`src/ontology/vbo-edit.obo`** — Primary ontology source file (OBO format). This is where breed terms are defined.
- **`src/ontology/vbo.Makefile`** — Custom make targets (Google Sheets sync, DADIS sync, Wikidata import, merge templates). Edit this, NOT the auto-generated `Makefile`.
- **`src/ontology/vbo-odk.yaml`** — ODK configuration. Defines imports, components, release settings.
- **`src/ontology/vbo-idranges.owl`** — ID range allocations for editors.
- **`src/ontology/components/`** — TSV template files downloaded from Google Sheets and the `axioms.owl` component.
- **`src/ontology/imports/`** — External ontology imports (ncbitaxon, ro, wikidata, omo, cob).
- **`src/scripts/`** — Python scripts for DADIS API integration (requires `DADIS_API_KEY` env var).

### Release Artifacts (root `vbo.*` and `vbo-*.owl`)
- `vbo-full` (primary release), `vbo-base`, `vbo-simple` in OWL/OBO/JSON formats.

## OBO Term Structure

Breed terms follow this pattern:
```obo
[Term]
id: VBO:0000038
name: Alpaca breed
def: "A breed of Vicugna pacos." [] {source="orcid..."}
subset: transboundary
synonym: "Alpaca" EXACT most_common_name [] {source="https://www.fao.org/dad-is"}
is_a: NCBITaxon:30538 {source="..."} ! Vicugna pacos
is_a: VBO:0400000 {source="..."} ! Vertebrate breed
property_value: dcterms:contributor https://orcid.org/...
property_value: dcterms:source "https://www.fao.org/dad-is" xsd:anyURI
```

Key conventions:
- VBO IDs are 7-digit zero-padded (e.g., `VBO:0000038`)
- Every breed needs a `most_common_name` synonym
- `is_a` relationships link to NCBITaxon species and VBO high-level breed classes
- Subsets: `local_breed`, `transboundary`, `national_breed_population`
- Sources are annotated with DOIs, PMIDs, ORCIDs, or URLs

## CI/CD

GitHub Actions runs QC on push to `master` and on PRs targeting `master` (`.github/workflows/qc.yml`). The test command is:
```
make ROBOT_ENV='ROBOT_JAVA_ARGS=-Xmx6G' test IMP=false PAT=false MIR=false
```
This runs ROBOT report validation without refreshing imports/mirrors for speed.

## Branch Conventions

- Main branch: `master`
- Feature branches: `issue-{number}` pattern
- Release tags: `vYYYY-MM-DD`
