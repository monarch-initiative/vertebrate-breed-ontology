# Merging and obsoleting classes

Terms to be obsoleted or merged should be reported in a [GitHub issue](https://github.com/monarch-initiative/vertebrate-breed-ontology/issues).
Obsoleted terms are maintained in a ROBOT Template which is the source for the “obsolete” component in VBO.

##Term merging
When merging a term (=obsolete_term) into another term (=merged_into_term)

1. Add the obsolete_term information (copied to the original ROBOT template) to the “obsolete” ROBOT template:

      1. **VBO ID**: _(required)_
      1. **TYPE**: _(required)_, should be “owl:Class”
      1. **owl:deprecated**: _(required)_, should be “true”
      1. **‘term replaced by’**: _(required)_ add the merged_into_term vbo id
      1. **‘has obsolescence reason’**:  _(required)_ write 'terms merged' in the literal field
      1. **‘term tracker item’**:  _(required)_, add the link to the GitHub issue where the obsoletion/merge was discussed, should be type ‘xsd:anyURI’
      1. **Comment**: _(optional)_

1. Add the obsolete_term information (copied to the original ROBOT template) to the “merged_into_term” (on the ROBOT template):
   1. The original obsolete_term label should be added as an exact synonym, with the original obsolete_term VBO id as a source
   1. Every other annotation and SubClassOf should be added to the “merged_into_term”, with their original source(s); review to ensure that there is no duplicate (when annotations are duplicate, add all sources under a single annotation). This includes:
      1. synonyms
      1. sources
      1. contributors
      1. xref
      1. Comment (note that only one comment is allowed per term, therefore comments might be merged
      1. SubClassOf

1. Remove the ‘obsolete_term’ from the original ROBOT template
1. Update components

##Term obsoletion (without merging)
1. Add the obsolete_term information (copied to the original ROBOT template) to the “obsolete” ROBOT template:
      1. **VBO ID**: _(required)_
      1. **LABEL**: _(required)_, add “obsolete” in front of the original template
      1. **TYPE**: _(required)_, should be “owl:Class”
      1. **owl:deprecated**: _(required)_, should be “true”
      1. **‘has obsolescence reason’**:  _(required)_
      1. **‘term tracker item’**’:  _(required)_, add the link to the GitHub issue where the obsoletion/merge was discussed, should be type ‘xsd:anyURI’
      1. Plus all the other annotations from the obsolete_term including their original source. This includes
         
            1. Synonyms
            2. Sources
            3. Contributors
            4. …
            5. **Do NOT** include SubClassOf
1. Remove the ‘obsolete_term’ from the original ROBOT template
1. Update components
