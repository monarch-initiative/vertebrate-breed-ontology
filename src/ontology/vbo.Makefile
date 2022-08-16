## Customize Makefile settings for vbo
##
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

NCBITRANSBOUND_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=896730834&single=true&output=tsv"
NCBIBREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=1721343081&single=true&output=tsv"
OMIATRANSBOUND_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=633566774&single=true&output=tsv"
OMIABREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=1354068566&single=true&output=tsv"
CATBREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vSw3inKWof-rHfvj9xmXhR-rbWKksacR6jmMTGKugorZG6KhHhEchLq9B3pGecuioyxan5LmC_45dVu/pub?gid=0&single=true&output=tsv"

.PHONY: sync_ncbitransbound
.PHONY: sync_ncbibreeds
.PHONY: sync_omiatransbound
.PHONY: sync_omiabreeds

sync_google_sheets:
	wget $(NCBITRANSBOUND_TEMPLATE) -O $(COMPONENTSDIR)/ncbitransbound.tsv
	wget $(NCBIBREEDS_TEMPLATE) -O $(COMPONENTSDIR)/ncbibreeds.tsv
	wget $(OMIATRANSBOUND_TEMPLATE) -O $(COMPONENTSDIR)/omiatransbound.tsv
	wget $(OMIABREEDS_TEMPLATE) -O $(COMPONENTSDIR)/omiabreeds.tsv
	wget $(CATBREEDS_TEMPLATE) -O $(COMPONENTSDIR)/catbreeds.tsv


$(COMPONENTSDIR)/%.owl: $(COMPONENTSDIR)/%.tsv $(SRC)
	if [ $(IMP) = true ]; then $(ROBOT) merge -i $(SRC) template --template $< --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --prefix "wikidata: http://www.wikidata.org/entity/" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@; fi


report-query-%:
	$(ROBOT) query --use-graphs true -i $(SRC) -f tsv --query $(SPARQLDIR)/reports/$*.sparql reports/report-$*.tsv

$(IMPORTDIR)/wikidata_terms_combined.txt: $(SRC) $(IMPORTDIR)/wikidata_terms.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --use-graphs true --query $(SPARQLDIR)/wikidata_terms.sparql $(TMPDIR)/wikidata_terms_combined.txt && \
	cat $(IMPORTDIR)/wikidata_terms.txt $(TMPDIR)/wikidata_terms_combined.txt > $@; fi

mirror-wikidata:
	echo "skipped"

mirror/wikidata.owl:
	echo "skipped"

$(TMPDIR)/wikidata_labels.ttl: $(IMPORTDIR)/wikidata_terms_combined.txt
	if [ $(IMP) = true ]; then cat $< | grep wikidata | runoak -i wikidata: search -O rdf --output $@ -; fi

#$(IMPORTDIR)/wikidata_import.ttl: $(TMPDIR)/wikidata_labels.txt
#	if [ $(IMP) = true ]; then echo "@prefix : <http://purl.obolibrary.org/obo/vbo/imports/wikidata_import.owl#> ." > $@ && \
#	echo "@prefix owl: <http://www.w3.org/2002/07/owl#> ." >> $@ && \
#	echo "@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> ." >> $@ && \
#	echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ." >> $@ && \
#	echo "@prefix wikidata: <http://www.wikidata.org/entity/> ." >> $@ && \
#	echo "@base <http://purl.obolibrary.org/obo/vbo/imports/wikidata_import.owl> ." >> $@ && \
#	echo "" >> $@ && \
#	echo "<http://purl.obolibrary.org/obo/vbo/imports/wikidata_import.owl> rdf:type owl:Ontology ." >> $@ && \
#	echo "" >> $@ && \
#	cat $< | sed "s/ ! / rdfs:label \"/g" | sed "s/$$/\" ./g" >> $@; fi

$(IMPORTDIR)/wikidata_import.owl: $(TMPDIR)/wikidata_labels.ttl
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/inject-synonymtype-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

.PHONY: wikidata
wikidata: $(IMPORTDIR)/wikidata_import.owl