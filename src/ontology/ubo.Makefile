## Customize Makefile settings for ubo
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile


SPECIES_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=0&single=true&output=tsv"
TRANSBOUNDARY_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=2117177699&single=true&output=tsv"
BREED_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=172866378&single=true&output=tsv"

.PHONY: sync_species
.PHONY: sync_transboundary
.PHONY: sync_breed

sync_google_sheets:
	wget $(SPECIES_TEMPLATE) -O $(COMPONENTSDIR)/species.tsv
	wget $(TRANSBOUNDARY_TEMPLATE) -O $(COMPONENTSDIR)/transboundary.tsv
	wget $(BREED_TEMPLATE) -O $(COMPONENTSDIR)/breeds.tsv


$(COMPONENTSDIR)/%.owl: $(COMPONENTSDIR)/%.tsv $(SRC)
	$(ROBOT) merge -i $(SRC) template --template $< --prefix "UBO: http://purl.obolibrary.org/obo/UBO_" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@
