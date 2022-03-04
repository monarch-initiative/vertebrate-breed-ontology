## Customize Makefile settings for vbo
##
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

NCBITRANSBOUND_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=896730834&single=true&output=tsv"
NCBIBREEDS_TEMPLATE="https://docs.google.com/spreadsheets/d/e/2PACX-1vRUoJ2t9244HHviSsC-Q6q59dxVBUMi85NUkWQFkIz87mUZ9wVqWyJ9foNJWl_Pkr3lFj57NJzpodBc/pub?gid=1721343081&single=true&output=tsv"

.PHONY: sync_ncbitransbound
.PHONY: sync_ncbibreeds

sync_google_sheets:
	wget $(NCBITRANSBOUND_TEMPLATE) -O $(COMPONENTSDIR)/ncbitransbound.tsv
	wget $(NCBIBREEDS_TEMPLATE) -O $(COMPONENTSDIR)/ncbibreeds.tsv


$(COMPONENTSDIR)/%.owl: $(COMPONENTSDIR)/%.tsv $(SRC)
	$(ROBOT) merge -i $(SRC) template --template $< --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/$@ -o $@


report-query-%:
	$(ROBOT) query --use-graphs true -i $(SRC) -f tsv --query $(SPARQLDIR)/reports/$*.sparql reports/report-$*.tsv

MERGE_TEMPLATE=tmp/merge_template.tsv
TEMPLATE_URL=https://docs.google.com/spreadsheets/d/e/2PACX-1vTV6ITR7RJMt5jswUHBmEEcfbNAeZWpj4VkDbMY3Bvh_fcmfXEw1CFvbgzOUPDxsj6oT5vsFQRg8FuM/pub?gid=346126899&single=true&output=tsv

tmp/merge_template.tsv:
				wget "$(TEMPLATE_URL)" -O $@

merge_template: $(MERGE_TEMPLATE)
					$(ROBOT) template --prefix "VBO: http://purl.obolibrary.org/obo/VBO_" --merge-before --input $(SRC) \
					--template $(MERGE_TEMPLATE) convert -f obo -o $(SRC)
