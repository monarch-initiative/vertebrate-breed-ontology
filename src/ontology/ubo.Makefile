## Customize Makefile settings for ubo
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile


BREED_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRoCfE7pmD0NTnQQnuWcIuEsbNk4p6f2c2LKC_BC7XQXRwXz4t69b0uyld7_dnjRKg5kmxynyrVBfG3/pub?gid=1428308388&single=true&output=tsv"

.PHONY: sync_breed
sync_google_sheets:
	wget $(BREED_TEMPLATE) -O $(COMPONENTSDIR)/breeds.tsv

$(COMPONENTSDIR)/%.owl: $(COMPONENTSDIR)/%.tsv $(SRC)
	$(ROBOT) merge -i $(SRC) template --template $< --prefix "UBO: http://purl.obolibrary.org/obo/UBO_" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@
