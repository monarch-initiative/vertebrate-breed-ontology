# VBO Classification

## High-level classification
VBO breed terms are classified under the general term ‘Vertebrate breed’ (VBO:0400000) and grouped based on specific animal species (e.g., ‘Dog breed’) or group of animals of the same genus (‘Cattle breed’) based on community and expert usage and jargon. 

**VBO high-level classification:** 

<img src="image.png" width="300">


## VBO is integrated within the NCBITaxon hierarchy.
Breeds are identified as distinctive groups within a family, genus, or species. Therefore, in the ontology, breeds are subclasses of family/genus/species represented by NCBITaxon entities. 
Based on the broad definition of vertebrate breed, “a group of animals that share specific characteristics that distinguish it from other organisms of the same family/genus/species (...)”, breeds were created as subclasses of family/genus/species, which are represented by the NCBITaxon entities. Hence VBO terms are integrated within the NCBITaxon hierarchy using the is_a relation. 
One of the advantages is that VBO terms can be autoclassified based on the NCBITaxon hierarchy.

**Example:** ‘Cattle breed’ (VBO:0400020) is defined as: ‘Vertebrate breed’ **and** Bos (NCBITaxon:9903). Bos indicus (zebu cattle, NCBITaxon:9915), Bos taurus (cattle, NCBITaxon:9913), Bos indicus × Bos taurus (hybrid cattle, NCBITaxon:30522), and Bos grunniens (yak, NCBITaxon:30521), are all autoclassified as ‘Cattle breed’ via the NCBITaxon hierarchy.

<img src="Screenshot 2024-07-30 at 12.52.48 PM.png" width="800">

## Sub-breeds, strains, variety, etc
Distinguishable sub-breeds, strains, or varieties are also included in VBO and are related to the ontological parent breed using an is_a relation.17–19 For example, 'Chihuahua, Long-Haired (Dog)' (VBO:0200339) and 'Chihuahua, Smooth-Haired (Dog)' (VBO:0200340) are subclasses of 'Chihuahua (Dog)' (VBO:0200338).

<img src="Screenshot 2024-07-30 at 12.49.22 PM.png" width="350">

## DAD-IS Breeds reported in a specific country
Breeds defined as having been reported in a specific country by National Coordinators in DAD-IS are either 
- direct subclasses of their corresponding NCBITaxon (see cattle breeds above: 'Guraghe, Ethiopia (Cattle)', subclass of _Bos indicus_)
- subclasses of other breeds (see cattle breeds above: 'Aberdeen Angus, Brazil (Cattle)', subclass of 'Aberdeen-Angus (Cattle)')
