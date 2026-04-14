---
name: automated-foundation-stock
description: Extract and cross-reference foundation stock (ancestor breed) relations from kennel club registry websites for a given species. Use when the user wants to build or update foundation stock data from breed registry sources.
argument-hint: [species] [optional: source URL]
---

# Automated Foundation Stock Relations

Extract `has foundation stock` (VBO:0300019) relations from kennel club registry breed pages and cross-reference across sources for confidence scoring.

## Axiom Definition

Foundation stock is a **directional ancestor relationship**: the subject breed is the descendant, the foundation stock breed is the ancestor used in its creation. A breed merely mentioned on a page is NOT foundation stock. See: https://monarch-initiative.github.io/vertebrate-breed-ontology/ontologymodeling/axioms/

## Process

### Step 1: Identify Sources

For $ARGUMENTS, identify the relevant breed registry websites. Known sources for dogs:
- **UKC** (United Kennel Club): https://www.ukcdogs.com/ - breed history sections
- **RKC** (Royal Kennel Club, UK): https://www.royalkennelclub.com/search/breeds-a-to-z/ - "About this breed" sections
- **CKC** (Canadian Kennel Club): https://www.ckc.ca/en/Choosing-a-Dog/Choosing-a-Breed/All-Dogs - "Origin" sections

For other species, the user will provide source URLs.

### Step 2: Fetch Breed Directory

For each source:
1. Fetch the breed directory/index page to get all breed URLs
2. Organize breeds into batches of ~20-25 for parallel fetching

### Step 3: Extract Foundation Stock Data

For each breed page, extract:
- **Breed name** as stated on the page
- **Foundation stock breeds** - ONLY breeds explicitly described as ancestors, crossed to create, or used in developing the breed
- **Exact quote** from the source text
- **Confidence of language** - distinguish between:
  - High: "was created by crossing X and Y", "descended from X"
  - Medium: "it is thought that X was used", "may have X in its background"
  - Low: "resembles X", "related to X" (these are NOT foundation stock)

**Critical filtering rules:**
- Do NOT include breeds that are merely mentioned, compared to, or listed as descendants
- Do NOT include generic types without a specific breed name (e.g., "terrier types", "local dogs")
- Do NOT include breeds described as descendants OF the subject breed (reverse direction)
- DO flag hedging language with REVIEW notes

### Step 4: Map to VBO IDs

Look up VBO identifiers for each breed name using `src/ontology/vbo-edit.obo`:
```python
# Parse OBO file for breed name -> VBO ID mapping
# Match on name field, case-insensitive, stripping " (Species)" suffix
```

Common name aliases to handle:
- "Old English Mastiff" = "English Mastiff"
- "German Wolfspitz" = "Keeshond"
- "St. Hubert Hound" = "Bloodhound"
- "Wavy-coated Retriever" = "Flat-Coated Retriever"

### Step 5: Create Per-Source TSV Files

One TSV per source with columns:
```
VBO ID | VBO label | foundation stock VBO ID | foundation stock VBO label | source URL | review_flag
```

Flag entries for:
- `REVIEW: circular` - A lists B as foundation stock AND B lists A
- `REVIEW: "hedging language"` - source uses uncertain language (quote it)
- `REVIEW: VBO ID needed` - could not map to a VBO identifier
- `REVIEW: reverse relationship` - the listed "ancestor" is actually a descendant
- `REVIEW: generic type` - source names a broad category, not a specific breed

### Step 6: Cross-Reference and Combine

Merge all source TSVs into a combined file with confidence tiers:

```
VBO ID | VBO label | foundation stock VBO ID | foundation stock VBO label | confidence tier | sources | source count | review flags | source URLs
```

**Confidence tiers:**
| Tier | Criteria |
|------|----------|
| `1 - all N sources` | All sources agree, highest confidence |
| `2 - multiple sources` | 2+ sources agree, no flags |
| `2b - multiple sources (flagged)` | 2+ sources agree but flagged |
| `3 - single source` | Only one source, no flags |
| `3b - single source (flagged)` | Only one source and flagged |

Sort by tier (highest first), then alphabetically by breed.

### Step 7: Summary

Report:
- Total unique relations found
- Breakdown by confidence tier
- Count of flagged entries by flag type
- Any breeds with no foundation stock data across all sources

## Output Files

Place all output in `src/ontology/`:
- `{species}_foundation_stock.tsv` - primary source data (retain existing if updating)
- `{species}_foundation_stock_{source}.tsv` - per additional source
- `{species}_foundation_stock_combined.tsv` - cross-referenced combined file
- `{species}_foundation_stock_README.md` - documentation

## Parallelization

Use background agents to fetch breed pages in parallel batches of ~20-25 URLs each. Launch multiple agents covering different letter ranges simultaneously. Compile results after all agents complete.
