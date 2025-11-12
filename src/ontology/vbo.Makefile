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
RELATION_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vTeekaFEi3bBh6PGvMr8-_cDSUBUiGyNOfTxTjzYQDaL5PfZeGBkX527U8du2kvY7YmphwT6Dddplp5/pub?gid=0&single=true&output=tsv"
OTHERBREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vQMQdvuC20xEeeXp9Ea8v1VqPEmOwHC0ucVvjgzZxwbQzODBjn0-UeNb9Zo98vUNHo9ltAPKWxG2hmQ/pub?gid=1074314048&single=true&output=tsv"

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
	wget $(RELATION_TEMPLATE) -O $(COMPONENTSDIR)/relation.tsv
	wget $(OTHERBREEDS_TEMPLATE) -O $(COMPONENTSDIR)/otherbreeds.tsv


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

# The below fix basically deals with a longstanding issue that the OBO format converter does not handle the 
# ObjectInverseOf axiom. This is a workaround until the issue is fixed in the OBO format converter
# https://github.com/OBOFoundry/COB/issues/229

.PHONY: mirror-cob
.PRECIOUS: $(MIRRORDIR)/cob.owl
mirror-cob: | $(TMPDIR)
	curl -L $(OBOBASE)/cob.owl --create-dirs -o $(TMPDIR)/cob-download.owl --retry 4 --max-time 200 && \
	$(ROBOT) convert -i $(TMPDIR)/cob-download.owl -f ofn -o $(TMPDIR)/$@.owl && \
	sed -i '/ObjectInverseOf/d' $(TMPDIR)/$@.owl

################################
##### Merge templates ##########
################################

MERGE_TEMPLATE=tmp/merge_template.tsv
#TEMPLATE_URL=https://docs.google.com/spreadsheets/d/e/2PACX-1vTV6ITR7RJMt5jswUHBmEEcfbNAeZWpj4VkDbMY3Bvh_fcmfXEw1CFvbgzOUPDxsj6oT5vsFQRg8FuM/pub?gid=346126899&single=true&output=tsv
TEMPLATE_URL=https://docs.google.com/spreadsheets/d/e/2PACX-1vTsgIbFYWkhMT0EgaBNbyT6fJiNKqVjdqcZxXQLwJ3CpXpSzB24BITZGDNSMyg_3bneIvE3F2l_iHWH/pub?gid=1886610709&single=true&output=tsv

tmp/merge_template.tsv:
	wget "$(TEMPLATE_URL)" -O $@

merge_template: $(MERGE_TEMPLATE)
	$(ROBOT) template --prefix "CHR: http://purl.obolibrary.org/obo/CHR_" --prefix "HGNC: http://identifiers.org/hgnc/" --prefix "sssom: https://w3id.org/sssom/" --merge-before --input $(SRC) \
 --template $(MERGE_TEMPLATE) convert -f obo -o $(SRC)


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

###########################################
##### Release preprocessing ###############
###########################################

$(EDIT_PREPROCESSED): $(SRC)
	$(ROBOT) merge --input $< --output $@.merged.owl
	owltools --use-catalog $@.merged.owl --merge-axiom-annotations -o -f owl $@.normalised.owl
	$(ROBOT) convert --input $@.normalised.owl --format ofn --output $@
