# VBO term Metadata

VBO terms have rich metadata, all associated with provenance. 

| Metadata                  | Annotation ID                                                | Description                                                                                                                                                                    |                                                                                   |
|---------------------------|--------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| VBO ID                    | http://www.geneontology.org/formats/oboInOwl#id              | The unique and permanent identifier of a VBO concept, using the VBO prefix (VBO).                                                                                              | required                                                                          |
| VBO Term Label            | http://www.w3.org/2000/01/rdf-schema#label                   | Single, unique label.                                                                                                                                                          | required                                                                          |
| Exact synonym             | http://www.geneontology.org/formats/oboInOwl#hasExactSynonym | Name by which a VBO term can be referred to.                                                                                                                                   | required for, “most common name” exact synonym, other exact synonyms are optional |
| Most common name          | http://purl.obolibrary.org/obo/vbo#most_common_name          | Synonym type, indicates the name by which a breed is most commonly referred to.                                                                                                | required                                                                          |
| Database cross reference  | http://www.geneontology.org/formats/oboInOwl#hasDbXref       | Identifier referring to the same VBO concept in another ontology, database, or the source.                                                                                     | optional                                                                          |
| Source                    | http://www.geneontology.org/formats/oboInOwl#source          | Added to an annotation, indicates the annotation provenance. When used as an annotation to the term, “source” represents the provenance of any information about the VBO term. | required                                                                          |
| Contributor               | dcterms:contributor                                          | ORCID of curators and experts who contributed to the creation/revision of a VBO term.                                                                                          | required                                                                          |
| Breed code                | http://purl.obolibrary.org/obo/vbo#breed_code                | Codes used by some communities, international organizations, and/or registration bodies to refer to the VBO term.                                                              | optional                                                                          |
| Breed recognition status  | http://purl.obolibrary.org/obo/vbo#breed_recognition_status  | Refers to the level of recognition by a registration body; may be ‘officially recognized’, ‘in the process of becoming officially recognized’, or ‘not been recognized’.       | optional                                                                          |
| Domestication status      | http://purl.obolibrary.org/obo/vbo#hasdomesticationstatus    | Refers to the breed as domestic, feral or wild.                                                                                                                                | optional                                                                          |
| Extinction status         | http://purl.obolibrary.org/obo/VBO_0300009                   | Breed status referring to the risk of extinction of a breed.                                                                                                                   | optional                                                                          |
| Description of origin     | http://purl.obolibrary.org/obo/vbo#origindescription         | Free text note that may include the geographical origin and foundation stock of a breed.                                                                                       | optional                                                                          |
| Comment                   | rdfs:comment                                                 | Information on specific terms and term usage.                                                                                                                                  | optional                                                                          |
| In subset - transboundary | http://www.geneontology.org/formats/oboInOwl#inSubset        | Indicate that the term is reported as a “transboundary breed” in DAD-IS                                                                                                        | optional DAD-IS only                                                              |
| Term tracker | http://purl.obolibrary.org/obo/IAO_0000233        | Link to relevant GitHub issue(s) that include discussion and decision on the VBO term.                                                                                                         | optional                                                               |

## VBO ID

- Unique and permanent identifiers
- IRI format: http://purl.obolibrary.org/obo/VBO_####### (7-digit)
- OBO ID format: VBO:####### (7-digit)

Example:  VBO:0200406 has the unique ID: http://purl.obolibrary.org/obo/VBO_0200406 

More information on term ID ranges is provided here [link to VBO developer documentation].


## VBO Term Label

Term labels are unique and follow the format: 
- **'Most common name (Species)’**
in which Species is the English name (e.g. 'Chihuahua (Dog)' (VBO:0200338)). 
- **'Most common name, Country; (Species)'**
in which Country and Species are the English names. (e.g., ‘Jersey Giant, Canada (Chicken)’ (VBO:0006068)). This format is used for breeds defined by their country of existence as reported by FAO National Coordinators in DAD-IS.

See more explanation in the [term labels and naming conventions](ontologymodeling/term-labels-naming-conventions.md) section.

## Exact synonym

Any name that is provided by breed sources that represents the same concept as the VBO term is added as an exact synonym. 

Example: “Teckel” is an exact synonym for 'Dachshund (Dog)' (VBO:0200406) 

Notes: 
- Source(s) for the exact synonym is(are) required. 
- “Exact synonyms” are optional, except for the one representing the ‘most common name’ of the breed (see below) which is required. 

## Most Common name

'Most common name' is a ‘synonym_type’ annotation property that is added to an ‘exact synonym’ to indicate that the name is the one most commonly used across sources when refering to the VBO term. 

Example, ‘Dachshund’ is the ‘most common name’ for VBO:0200406

## Database cross-reference

- A database cross-reference is an identifier in another ontology, database, or the source that refers to the same concept.
- Database cross-reference is in the CURIE format

Example: ‘Angus (Cattle)’ (VBO:0000104) has database_cross_reference LBO:0000017. 

The “source” annotation for the database cross reference is the provenance for this mapping between VBO and the other source. Currently, the provenance is the ORCID of the contributor [link to contributor section] who manually curated this mapping.

## Source

VBO was created based on information available in breed communities, international breed organizations, literature, and personal communication with experts. We keep the provenance of all this information in the “source” annotation. This “source” annotation property can be used to annotate metadata and SubClass axioms. When used as an annotation to the term, “source” represents the provenance of any information about the VBO term.

"Source" can refer to
- a specific record in a database or other ontology 
   - e.g. 'Abyssinian (Horse)' (VBO:0017087) has source LBO:0000714
- a publication 
   - e.g. 'Spanish Jennet (Horse)' (VBO:0016895) has source ISBN:9781403966216
- an international breed organization 
   - e.g. 'Schnauzer, Standard (Dog)' (VBO:0201189) has source https://www.akc.org/dog-breeds/standard-schnauzer/
- individual experts 
   - e.g. 'Göttingen minipig (Pig)' (VBO:0016899) has source for exact synonym ‘Goettingen miniature pig’ https://orcid.org/0000-0002-5520-6597


## Contributor

Curators and experts who contributed to the creation of a VBO term are recorded by adding their ORCID, using the annotation property “dcterms:contributor”.

Example: 'American Shorthair (Cat)' (VBO:0100018) has dcterms:contributor https://orcid.org/0000-0002-1628-7726 

## Breed code

Some breed communities, international breed organizations, and/or registration bodies refer to breeds using codes. These codes are used on registration papers and for competition purposes. Breed codes are therefore of importance for some users. The same codes are often, though not always, reused between communities.

We recorded breed code as annotations using the annotation property “breed code”. Since codes are not always the same across communities, the source for the breed codes are recorded.

Example: 'Abyssinian (Cat)' (VBO:0100000) is known by the breed code, ‘AB’ by TICA and ‘ABY’ by several other cat organizations, FIFe, WCF, GCCF and REFR.

<img src="Screenshot 2024-07-30 at 7.33.45 PM.png" width="400">

## Breed recognition status

We took an inclusive approach and created a VBO term when “any” sources described a group of animal as a breed. However, what is considered a “breed” can vary between these sources, and this breed recognition can be of importance to some communities. For example, only breeds officially recognized by registration bodies determine eligibility of an animal to compete in a championship.

We recorded the breed recognition status in VBO as an annotation, using the annotation property ‘breed_recognition_status’ , and a  VBO ‘recognition status’ (VBO:0300001) term. These ‘recognition status’ terms could be: 

| VBO terms   | Term labels                | Definitions                                                                                                                                                                                                                  |
|-------------|----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| VBO:0300002 | fully recognized breed     | Breed recognition status referring to a breed recognized by an international registration body. This status also refers to breeds that are eligible to compete in championship classes.                                      |
| VBO:0300003 | partially recognized breed | Breed recognition status referring to a breed that is in the process of becoming fully recognized by an international registration body. This status is given to breeds which are preliminarily or provisionally recognized. |
| VBO:0300004 | not recognized breed       | Breed recognition status referring to a breed that is reported by an international registration body but not recognized.                                                                                                     |

It should be noted that a same breed could have more than one ‘breed recognition status’ depending on the provenance of the information. All current available information is recorded in VBO , and provenance for this ingormation is recorded as a “source” annotation.
This following example is a breed with multiple “breed recognition status”: 

<img src="Screenshot 2024-07-30 at 8.16.58 PM.png" width="400">

## Domestication status

The definition of Vertebrate Breed [REF] in VBO implies that a group of animals can be considered as a breed regardless of their domestication status. This domestication status can be of importance in some communities, for example in DAD-IS and the FAO, therefore, we recorded that information when available. 

We recorded the breed domestication status in VBO as an annotation, using the annotation property ‘has_domestication_status’. The domestication status can be one of the following terms:

| VBO terms   | Term labels    | Definitions                                                                                                                                                                                      |
|-------------|----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| VBO:0300006 | feral breed    | Domestication status given to a group of animals that has been domesticated and has adapted to existence in the wild state but remains distinct from other wild individuals of the same species. |
| VBO:0300007 | domestic breed | Domestication status given to a group of animals that has been domesticated, that is have been selectively bred and genetically adapted over generations to live alongside humans.               |
| VBO:0300008 | wild breed     | Domestication status given to a group of animals that has not been domesticated and exists as free-living, self-sustaining and unmanaged population.                                             |

As with all metadata, the source of information is recorded. Currently, the domestication status information solely comes from DAD-IS.

Examples:

<img src="Screenshot 2024-07-31 at 3.41.53 PM.png" width="250">
<img src="Screenshot 2024-07-31 at 3.42.25 PM.png" width="200">
<img src="Screenshot 2024-07-31 at 3.42.56 PM.png" width="250">

## Extinction status

_upcoming_

## Description of origin

Information about the breed origin, including information about the foundation stock used to create a breed, is often available in the form of free text notes. The free text note format is not ideal for querying information, but since this information is useful to some users, we recorded it, as reported by the sources (i.e. in free text note format), using the annotation property “description of origin” (http://purl.obolibrary.org/obo/vbo#origindescription). As for all other metadata, the source for the information is included.

It should be noted that 
- ongoing work aims to review the ‘description of origin’ information and create ‘has_foundation_stock’ axioms to record this information in a more semantically useful format
- some information beyond the description of origin is sometimes included. 

<img src="Screenshot 2024-07-31 at 4.00.31 PM.png" width="500">

## Comment

Information on term concepts and usage are provided in the comment.

Example: 

<img src="Screenshot 2024-07-31 at 4.04.05 PM.png" width="500">


## In subset - transboundary

Users requested a way to identify VBO terms corresponding to DAD-IS transboundary breeds (read more about transboundary breeds and DAD-IS HERE). To support users of the DAD-IS data, we added a subset annotation to these VBO terms. 
The annotation uses the “in subset” (http://www.geneontology.org/formats/oboInOwl#inSubset) annotation property, with the “transboundary” annotation. 

Example: 

<img src="Screenshot 2024-07-31 at 4.12.45 PM.png" width="300">

## Term tracker

All ontology updates are tracked in our [GitHub repository](https://github.com/monarch-initiative/vertebrate-breed-ontology). When an update or edit on a VBO term is made in the context of a GitHub issue, a link to GitHub issue is added the VBO term. 
These links are useful to keep track of editing history (e.g. what changes were made) and for transparency (i.e. one can go back to a GitHub issue to gain context on the discussions and decisions that lead to the changes in the VBO term).