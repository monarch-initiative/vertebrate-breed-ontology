![Build Status](https://github.com/monarch-initiative/vertebrate-breed-ontology/workflows/CI/badge.svg)
[![DOI](https://zenodo.org/badge/437063372.svg)](https://zenodo.org/badge/latestdoi/437063372)

# Vertebrate Breed Ontology (VBO)

The **Vertebrate Breed Ontology (VBO)** is a standardized, computable resource for vertebrate breed names. It provides consistent breed terminology (including synonyms) across species, enabling interoperability between databases and research systems.

VBO is part of the [OBO Foundry](http://obofoundry.org/ontology/vbo) and is maintained by the [Monarch Initiative](https://monarchinitiative.org/).

## Why VBO?

Breed names across databases and literature are often inconsistent, duplicated, or erroneous. VBO solves this by providing a single controlled vocabulary for breed names, built primarily from the FAO's [Domestic Animal Diversity Information System (DAD-IS)](https://www.fao.org/dad-is/data/en/) — the most comprehensive global breed resource, covering 15,000+ national breed populations across 8,800+ breeds and 38 species.

VBO also incorporates breed names not in DAD-IS (e.g., cat and dog breeds) and maps to other resources like the [Livestock Breed Ontology (LBO)](https://www.animalgenome.org/bioinfo/projects/lbo/).

## Who Uses VBO?

- [**OMIA**](https://omia.org) — Online Mendelian Inheritance in Animals, a catalog of inherited disorders and traits in vertebrates, hosted by the University of Sydney.
- [**AHIDA**](https://www.sydney.edu.au/science/our-research/research-areas/life-and-environmental-sciences/sydney-school-of-veterinary-science/anstee-hub-for-inherited-diseases-in-animals.html) — Anstee Hub for Inherited Diseases of Animals, a surveillance and reporting resource for inherited diseases.

## Download

The latest stable release:

- **OWL**: http://purl.obolibrary.org/obo/vbo.owl
- **OBO**: http://purl.obolibrary.org/obo/vbo.obo
- **JSON**: http://purl.obolibrary.org/obo/vbo.json

For editors, the source file is [`src/ontology/vbo-edit.obo`](src/ontology/vbo-edit.obo).

## Contributing

We welcome contributions! You can:

- **Report issues or request new breeds**: [Open an issue](https://github.com/monarch-initiative/vertebrate-breed-ontology/issues)
- **Submit changes**: [Make a pull request](https://github.com/monarch-initiative/vertebrate-breed-ontology/pulls)

Helpful guides:
- [Managing GitHub issues](https://oboacademy.github.io/obook/tutorial/github-issues/)
- [Contributing to OBO ontologies](https://oboacademy.github.io/obook/lesson/contributing-to-obo-ontologies/)

## License

[CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/)

## Contact

Use the [Issue tracker](https://github.com/monarch-initiative/vertebrate-breed-ontology/issues) for questions, term requests, or bug reports.

## Acknowledgements

- Built using the [Ontology Development Kit (ODK)](https://github.com/INCATools/ontology-development-kit)
- Breed data sourced in collaboration with FAO colleagues responsible for DAD-IS
- Inspired by the [Livestock Breed Ontology (LBO)](https://www.animalgenome.org/bioinfo/projects/lbo/) from Iowa State University
