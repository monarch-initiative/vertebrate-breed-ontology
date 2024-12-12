# Axioms in VBO

Logical axioms are relational information about classes that are primarily aimed at machines. They relate terms within the same ontology and across ontologies. They provide context, allow reasoners to assist in and verify classification, and support complex computational queries. 
Read more information about logical axiomatization [here](https://oboacademy.github.io/obook/explanation/logical-axiomatization/).


## “has foundation stock” axiom

Breeds are often created by crossing other breeds whose traits and/or pedigrees are desirable. The animals that are the progenitors, or foundation, of a breed are called “foundation stock”; they provide part of the underlying genetic base for a new distinct population [https://en.wikipedia.org/wiki/Foundation_stock] (https://en.wikipedia.org/wiki/Foundation_stock). Knowing the “foundation stock(s)” of a breed is often of great interest for example in breeding programs to understand the frequency of a disease allele in a population.  

**Object**: VBO term representing a breed
“has foundation stock” axiom is added to a VBO term representing a breed (it should be noted that there is no indication in the ontology whether a term represents a breed, a sub-breed, a variety, etc). The following terms should not have a “has foundation stock” SubClassOf annotation: 
- NCBITaxom term representing a species, genus, family, etc.
- VBO term representing a grouping class (e.g. “dog breed”, “cattle breed”, etc.)

**Relation**: has foundation stock

- ‘has foundation stock’ (VBO:0300019). 
It should be noted that this relation is currently created in VBO. We plan on submitting it to the Relation Ontology (RO). If in scope, new relations are created in RO, the RO term will replace the current VBO relation.
- Definition: “a relation between two distinct material entities (breeds or species), a descendant entity and an ancestor entity, in which the descendant entity is the result of mating, manipulation, or geographical or cultural isolation of the ancestor entity, therefore inheriting some of the ancestor’s genetic material.” 

**Target**: VBO term or NCBITaxon term
Targets allowed includes: 
- VBO term representing a breed
   - example: ‘Cymric (Cat)’ VBO:0100080 has foundation stock ‘Manx (Cat)’ VBO:0100156
- NCBITaxon representing species
   - Breed created by crossing with “wild” animals of the same species. 
   - Breed created by crossing with a group of animals from another species (where no actual breed of this another species is recorded): 
        - example: ‘Kanaani (Cat)’ VBO:0100137 has foundation stock ‘African Wildcat’ NCBITaxon:61377

**Notes**:
- A term can have multiple “has foundation stock” SubClassOf 
   - example: 'Himalayan (Cat)' (VBO:0100117) was created from a cross of individuals from 'Siamese (Cat)' (VBO:0100221) and 'Persian (Cat)' (VBO:0100188) 
- A lot of the information about “foundation stock” is provided in breed descriptions and histories issued by the breed sources. These sources are recorded as “source” annotation of the SubClassOf axiom. 
- Currently, a lot of “foundation stock” information is available in the “description of origin” annotation, and not yet as “SubClassOf” annotation. Work is underway to extract this information from the free text note to create these “SubClassOf” annotations.
 
## “breed reported in geographic location” axiom

Most breeds in [DAD-IS] (https://www.fao.org/dad-is/en/) represent breed populations that exist in a specific country as reported by officially nominated National Coordinators. Therefore the concept of these DAD-IS breeds specifically represent a “breed that exists in a specific country”. This concept is unique to DAD-IS and its goals [https://www.fao.org/dad-is/en/] (https://www.fao.org/dad-is/en/).

**Object**: VBO term representing a DAD-IS “local breeds” or “national breed population” 
- “national breed population” refers to the existence of a particular breed in a particular country. For example, a breed of chicken called “Alatau” reported to exist in Kyrgyzstan (VBO:0007427)
- “local breed” refers to a country specific instance of a same breed that exists in each of several countries (itself called “transboundary” breed). (Example: ‘Jersey Giant, Canada (Chicken)’ (VBO:0006068) and 'Jersey Giant, Ireland (Chicken)' (VBO:0006071) are local breeds with the transboundary parent term 'Jersey Giant (Chicken)' (VBO:0000547))

**Relation**: breed reported in geographic location

- ‘breed reported in geographic location’ (VBO:0300020). 
It should be noted that this relation is currently created in VBO. We plan on submitting it to the Relation Ontology (RO). If in scope, new relations are created in RO, the RO term will replace the current VBO relation.
- Definition: “a relation between a breed and the geographic location where the breed was reported to exist by country-nominated FAO National Coordinators.” 

**Target**: Country (Wikidata ID for country)

**Notes**: 
- This SubClassOf should **only** be used for breeds reported from DAD-IS, i.e., representing a breed defined as existing in a country. This concept will rarely exists outside of DAD-IS.
- VBO terms with this SubClassOf axiom should have the following rdfs:comment, "The concept of “breed reported in geographic location by FAO National Coordinators” is unique to DAD-IS [https://www.fao.org/dad-is/en/] (https://www.fao.org/dad-is/en/). This VBO term should therefore be used specifically for the breed conforming to this concept."