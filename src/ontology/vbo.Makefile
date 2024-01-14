## Customize Makefile settings for vbo
##
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

DADISTRANSBOUND_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vTfv8VmGblrTMx1inxHAmPeCmkXCl7D4TxlyOWnAsinQ87YpCmVXGmi19uo42Kkliqhec4mfYl_AQUK/pub?gid=1655315858&single=true&output=tsv"
DADISBREEDCOUNTRY_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vTfv8VmGblrTMx1inxHAmPeCmkXCl7D4TxlyOWnAsinQ87YpCmVXGmi19uo42Kkliqhec4mfYl_AQUK/pub?gid=730920235&single=true&output=tsv"
LIVESTOCKBREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vSZscW_RQjFZEFMrzZBeutPSQeeUYqRfBx8C9Lyn7xCjeTDGOBXwvMscreBcuphlVtaQ9VfPR-N4Lmi/pub?gid=1074314048&single=true&output=tsv"
CATBREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vQgt4XnMZ8dW1QMSGruZQtBTn304EkiULF1yS7cl-Otm2d2q9OsVcEfVcN3aLQXPO4-Djem8jMHh9N-/pub?gid=1655315858&single=true&output=tsv"
DOGBREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vSuwLXikgq08frK7d8yFSdWTS8P1erx5bS_QiLdHhfKV4ulJlRrqkVaVhC7b3O6Z8ixrvJgoCBy8YLq/pub?gid=1655315858&single=true&output=tsv"
BREEDSTATUS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vTk1AOht1rOoyXExlZu9KzCOtfIOoTGBxkVmJ6dvE9wuQ1Q7LfwMA93vF0yRPpG7GMq03mKFdV74YnG/pub?gid=1650821837&single=true&output=tsv"
HIGHLEVELCLASS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRpjOwuI9e1Imkdp40nPTw5cNKFjdpV9fHSHDIfcdXfod41sSogjFhWfas8Cjdpfa4lEVR0GyYxFDrE/pub?gid=2041564448&single=true&output=tsv"

.PHONY: sync_dadistransbound
.PHONY: sync_dadisbreedcountry


sync_google_sheets:
	wget $(DADISTRANSBOUND_TEMPLATE) -O $(COMPONENTSDIR)/dadistransbound.tsv
	wget $(DADISBREEDCOUNTRY_TEMPLATE) -O $(COMPONENTSDIR)/dadisbreedcountry.tsv
	wget $(LIVESTOCKBREEDS_TEMPLATE) -O $(COMPONENTSDIR)/livestockbreeds.tsv
	wget $(CATBREEDS_TEMPLATE) -O $(COMPONENTSDIR)/catbreeds.tsv
	wget $(DOGBREEDS_TEMPLATE) -O $(COMPONENTSDIR)/dogbreeds.tsv
	wget $(BREEDSTATUS_TEMPLATE) -O $(COMPONENTSDIR)/breedstatus.tsv
	wget $(HIGHLEVELCLASS_TEMPLATE) -O $(COMPONENTSDIR)/highlevelclass.tsv


$(COMPONENTSDIR)/%.owl: $(COMPONENTSDIR)/%.tsv $(SRC)
	if [ $(COMP) = true ]; then $(ROBOT) merge -i $(SRC) template --template $< --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --prefix "wikidata: http://www.wikidata.org/entity/" --output $@ && \
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

dependencies:
	pip install -U pip && pip install -U oaklib

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

$(COMPONENTSDIR)/dadisbreedcountry.tsv:
	pip install -U pip && pip install pydantic==2.5.3 pandas==2.1.4
	python ../scripts/dadisbreedcountry-sync.py $@

.PHONY: dadisbreedcountry
dadis-sync: $(COMPONENTSDIR)/dadisbreedcountry.owl
