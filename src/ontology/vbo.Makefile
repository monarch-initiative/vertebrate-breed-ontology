## Customize Makefile settings for vbo
##
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

########################################
##### Google sheets templates ##########
########################################

DADISTRANSBOUND_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vTfv8VmGblrTMx1inxHAmPeCmkXCl7D4TxlyOWnAsinQ87YpCmVXGmi19uo42Kkliqhec4mfYl_AQUK/pub?gid=1655315858&single=true&output=tsv"
DADISBREEDCOUNTRY_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vTfv8VmGblrTMx1inxHAmPeCmkXCl7D4TxlyOWnAsinQ87YpCmVXGmi19uo42Kkliqhec4mfYl_AQUK/pub?gid=730920235&single=true&output=tsv"
LIVESTOCKBREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vSZscW_RQjFZEFMrzZBeutPSQeeUYqRfBx8C9Lyn7xCjeTDGOBXwvMscreBcuphlVtaQ9VfPR-N4Lmi/pub?gid=1074314048&single=true&output=tsv"
CATBREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vQgt4XnMZ8dW1QMSGruZQtBTn304EkiULF1yS7cl-Otm2d2q9OsVcEfVcN3aLQXPO4-Djem8jMHh9N-/pub?gid=1655315858&single=true&output=tsv"
DOGBREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vSuwLXikgq08frK7d8yFSdWTS8P1erx5bS_QiLdHhfKV4ulJlRrqkVaVhC7b3O6Z8ixrvJgoCBy8YLq/pub?gid=1655315858&single=true&output=tsv"
BREEDSTATUS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vTk1AOht1rOoyXExlZu9KzCOtfIOoTGBxkVmJ6dvE9wuQ1Q7LfwMA93vF0yRPpG7GMq03mKFdV74YnG/pub?gid=1650821837&single=true&output=tsv"
HIGHLEVELCLASS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRpjOwuI9e1Imkdp40nPTw5cNKFjdpV9fHSHDIfcdXfod41sSogjFhWfas8Cjdpfa4lEVR0GyYxFDrE/pub?gid=2041564448&single=true&output=tsv"
LBO_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vTiIZWsHBBfApE4jIXNp8O-c6gf1MJ-g79sLC6o6hxUDKb9ISvZjtwmv_jv6oMhQ0b0w4SYAlQ7WqmY/pub?gid=559994719&single=true&output=tsv"

dependencies:
	pip install -U pip && pip install -U oaklib

sync_google_sheets:
	wget $(DADISTRANSBOUND_TEMPLATE) -O $(COMPONENTSDIR)/dadistransbound.tsv
	wget $(DADISBREEDCOUNTRY_TEMPLATE) -O $(COMPONENTSDIR)/dadisbreedcountry.tsv
	wget $(LIVESTOCKBREEDS_TEMPLATE) -O $(COMPONENTSDIR)/livestockbreeds.tsv
	wget $(CATBREEDS_TEMPLATE) -O $(COMPONENTSDIR)/catbreeds.tsv
	wget $(DOGBREEDS_TEMPLATE) -O $(COMPONENTSDIR)/dogbreeds.tsv
	wget $(BREEDSTATUS_TEMPLATE) -O $(COMPONENTSDIR)/breedstatus.tsv
	wget $(HIGHLEVELCLASS_TEMPLATE) -O $(COMPONENTSDIR)/highlevelclass.tsv
	wget $(LBO_TEMPLATE) -O $(COMPONENTSDIR)/lbo.tsv

# NOTE TO EDITOR: FROM ODK 1.5. onwards, we need to add a goal for each component here:

$(COMPONENTSDIR)/dadistransbound.owl: $(COMPONENTSDIR)/dadistransbound.tsv $(SRC)
	if [ $(COMP) = true ]; then $(ROBOT) merge -i $(SRC) template --template $< --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --prefix "wikidata: http://www.wikidata.org/entity/" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@; fi

$(COMPONENTSDIR)/dadisbreedcountry.owl: $(COMPONENTSDIR)/dadisbreedcountry.tsv $(SRC)
	if [ $(COMP) = true ]; then $(ROBOT) merge -i $(SRC) template --template $< --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --prefix "wikidata: http://www.wikidata.org/entity/" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@; fi

$(COMPONENTSDIR)/livestockbreeds.owl: $(COMPONENTSDIR)/livestockbreeds.tsv $(SRC)
	if [ $(COMP) = true ]; then $(ROBOT) merge -i $(SRC) template --template $< --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --prefix "wikidata: http://www.wikidata.org/entity/" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@; fi

$(COMPONENTSDIR)/catbreeds.owl: $(COMPONENTSDIR)/catbreeds.tsv $(SRC)
	if [ $(COMP) = true ]; then $(ROBOT) merge -i $(SRC) template --template $< --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --prefix "wikidata: http://www.wikidata.org/entity/" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@; fi

$(COMPONENTSDIR)/dogbreeds.owl: $(COMPONENTSDIR)/dogbreeds.tsv $(SRC)
	if [ $(COMP) = true ]; then $(ROBOT) merge -i $(SRC) template --template $< --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --prefix "wikidata: http://www.wikidata.org/entity/" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@; fi

$(COMPONENTSDIR)/breedstatus.owl: $(COMPONENTSDIR)/breedstatus.tsv $(SRC)
	if [ $(COMP) = true ]; then $(ROBOT) merge -i $(SRC) template --template $< --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --prefix "wikidata: http://www.wikidata.org/entity/" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@; fi

$(COMPONENTSDIR)/highlevelclass.owl: $(COMPONENTSDIR)/highlevelclass.tsv $(SRC)
	if [ $(COMP) = true ]; then $(ROBOT) merge -i $(SRC) template --template $< --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --prefix "wikidata: http://www.wikidata.org/entity/" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@; fi

$(COMPONENTSDIR)/lbo.owl: $(COMPONENTSDIR)/lbo.tsv $(SRC)
	if [ $(COMP) = true ]; then $(ROBOT) merge -i $(SRC) template --template $< --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --prefix "wikidata: http://www.wikidata.org/entity/" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@; fi


################################
##### Reports ##################
################################

report-query-%:
	$(ROBOT) query --use-graphs true -i $(SRC) -f tsv --query $(SPARQLDIR)/reports/$*.sparql reports/report-$*.tsv

################################
##### Wikidata import ##########
################################

$(IMPORTDIR)/wikidata_terms_combined.txt: $(SRC) $(IMPORTDIR)/wikidata_terms.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --use-graphs true --query $(SPARQLDIR)/wikidata_terms.sparql $(TMPDIR)/wikidata_terms_combined.txt && \
	cat $(IMPORTDIR)/wikidata_terms.txt $(TMPDIR)/wikidata_terms_combined.txt > $@; fi

# Needs to be excluded as wikidata does not have a mirror step
mirror-wikidata:
	echo "skipped $@ - wikidata does not have a mirror step"

# Needs to be excluded as wikidata does not have a mirror step
mirror/wikidata.owl:
	echo "skipped $@ - wikidata does not have a mirror step"

$(TMPDIR)/wikidata_labels.ttl: $(IMPORTDIR)/wikidata_terms_combined.txt
	if [ $(IMP) = true ]; then cat $< | grep wikidata | runoak -i wikidata: search -O rdf --output $@ -; fi

$(IMPORTDIR)/wikidata_import.owl: $(TMPDIR)/wikidata_labels.ttl
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/inject-synonymtype-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

.PHONY: wikidata
wikidata: $(IMPORTDIR)/wikidata_import.owl

################################
##### DADIS sync ###############
################################

.PHONY: dadis-transboundary-sync
.PHONY: dadis-local-sync

ifeq ($(DADIS_API_KEY),)
dadis-local-sync:
	@echo "WARNING: DADIS_API_KEY not set, skipping dadisbreedcountry.tsv"

dadis-transboundary-sync:
	@echo "WARNING: DADIS_API_KEY not set, skipping dadistransbound.tsv"

else
dadis-local-sync:
	pip install "pydantic>=2.5.3" "pandas>=2.1.4"
	python ../scripts/find_dadis_local_ids.py --input_filename ./components/dadisbreedcountry.tsv --output_filename ./components/dadisbreedcountry.tsv

dadis-transboundary-sync:
	pip install "pydantic>=2.5.3" "pandas>=2.1.4"
	python ../scripts/find_dadis_transboundary_ids.py --input_filename ./components/dadistransbound.tsv --output_filename ./components/dadistransbound.tsv

endif

.PHONY: dadisbreedcountry
dadis-local-sync: $(COMPONENTSDIR)/dadisbreedcountry.owl

.PHONY: dadistransbound
dadis-transboundary-sync: $(COMPONENTSDIR)/dadistransbound.owl

###########################################
##### Release preprocessing ###############
###########################################

$(EDIT_PREPROCESSED): $(SRC)
	owltools --use-catalog  $(SRC) --merge-axiom-annotations -o -f owl $@.normalised.owl
	$(ROBOT) convert --input $@.normalised.owl --format ofn --output $@
