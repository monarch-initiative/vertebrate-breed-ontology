# Term labels and Naming Conventions

One can refer to the same breed by multiple names, including names in different languages (e.g. ‘Artois Hound’ and ‘Chien d’Artois’ refer to the same breed). In addition, the same name is often used to refer to different breeds, of different species. For example, “Tibetan” is the name for a breed of cattle, sheep, chicken, pig, goat, etc. However, a VBO term label must be unique, i.e. multiple terms cannot have the same label, even if their names are the same. In this document, we explain how VBO term labels were created to ensure uniqueness and uniformity. 

Breeds from different species often share the same name. For example, “Tibetan” is the name for a breed of cattle, sheep, chicken, pig, goat, etc. In addition, some breeds are commonly called by names that can represent other types of entities. For example “Cyprus” is used to refer to breeds of cattle, cat, etc., but also to the country “Cyprus”. 
To create unique VBO term labels, we concatenated the breed’s most common name and their species, following the format: `**'Most common name (Species)'**`, in which most common name and species are the English language names (e.g. 'Cyprus (Cat)' VBO:0100081).

The “Most common name” represents the breed name that is most often used to refer to the breed, as determined by the information found in the sources (_LINK to be added_). This ‘most common name’ is also recorded as an “exact synonym” [_LINK to be added_]. All breed names, including the one that are shared between breeds, are available as synonyms in VBO. For example, an exact synonym of Tibetan (Goat) VBO:0000845 is Tibetan. 

Including the ‘Species’ in the term label could be controversial. Breeds have a is_a relationship to a species, and therefore repeating the species name (ie ontological parentage) in the label is a break with standard ontology practices.  While we recognize that this solution is not ideal, we were unable to ensure term label uniqueness without including the species name in the term label. As exemplified above, breeds from different species can share the same name, and some breeds can share identical name with other types of entities such as countries. 


**The case of DAD-IS “national breed population” and “local breeds”.** 
DAD-IS is maintained by National Coordinators for the Management of Animal Genetic Resources, and therefore their concept of breed is closely tight to the country where a breed has been reported (read more about DAD-IS [here](_LINK to be added_)). 
DAD-IS distinguishes between: 
- “national breed population” which refers to the existence of a particular breed in a particular country. For example, a breed of chicken called “Alatau” reported to exist in Kyrgyzstan (VBO:0007427)
- “local breed” which refers to a country specific instance of a same breed that exists in each of several countries (itself called “transboundary” breed). (see example below)

As a consequence, it is very common to find breeds in DAD-IS with the same common name and from the same species. For example, “Jersey Giant” is a breed of chicken that exists in Canada, Ireland, Luxembourg, etc., with each instance of this breed in an individual county being considered as an individual breed record to be represented in VBO. 
The naming convention reported above, based on “most common name” and “species” is therefore not sufficient to ensure term label uniqueness for DAD-IS “national breed population” and “local breed”. The country where the breed has been reported by the National Coordinators had to be included to the VBO term label, following the format: 
`**'Most common name’, Country (Species)'**`, in which country and species are the English names (e.g ‘Jersey Giant, Canada (Chicken)’ VBO:0006068).

We recognize that adding the Ccuntry of existence in the term name, in addition to the species, is not ideal and is unusual to ontology practices, but this concatenation of attributes was the only viable solution to ensure term uniqueness. 
 
