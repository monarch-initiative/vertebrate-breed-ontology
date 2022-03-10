## Customize Makefile settings for vbo
##
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

NCBITRANSBOUND_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=896730834&single=true&output=tsv"
NCBIBREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=1721343081&single=true&output=tsv"
OMIATRANSBOUND_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=633566774&single=true&output=tsv"
OMIABREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=1354068566&single=true&output=tsv"

.PHONY: sync_ncbitransbound
.PHONY: sync_ncbibreeds
.PHONY: sync_omiatransbound
.PHONY: sync_omiabreeds

sync_google_sheets:
	wget $(NCBITRANSBOUND_TEMPLATE) -O $(COMPONENTSDIR)/ncbitransbound.tsv
	wget $(NCBIBREEDS_TEMPLATE) -O $(COMPONENTSDIR)/ncbibreeds.tsv
	wget $(OMIATRANSBOUND_TEMPLATE) -O $(COMPONENTSDIR)/omiatransbound.tsv
	wget $(OMIABREEDS_TEMPLATE) -O $(COMPONENTSDIR)/omiabreeds.tsv


$(COMPONENTSDIR)/%.owl: $(COMPONENTSDIR)/%.tsv $(SRC)
	$(ROBOT) merge -i $(SRC) template --template $< --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@


report-query-%:
	$(ROBOT) query --use-graphs true -i $(SRC) -f tsv --query $(SPARQLDIR)/reports/$*.sparql reports/report-$*.tsv
