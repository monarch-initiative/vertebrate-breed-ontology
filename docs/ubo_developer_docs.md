# UBO Developer Docs

## How to refresh components

### Refreshing ROBOT templates from Google Sheets:

```
cd src/ontology
sh run.sh make sync_google_sheets
```

This will download the Google sheets as TSV and store them in the `components` directory.

<a id="update_component" />

### Updating components:

```
cd src/ontology
sh run.sh make components/breeds.owl
```

This will refresh the breeds component based on the current ROBOT template stored in components/breeds.tsv.

## Adding entirely new components:

1. Add the name of the component to `src/ontology/ubo-odk.yaml` (in the `components/products` section, like `breeds.owl`).
2. Run `sh run.sh make update_repo`
3. Add the component to the `sync_google_sheets` `make` commmand in `ubo.Makefile`, essentially:
   - creating a new variable for it (like `BREED_TEMPLATE`)
   - adding a wget command underneat the one that is currrently there.

```
sync_google_sheets:
	wget $(BREED_TEMPLATE) -O $(COMPONENTSDIR)/breeds.tsv
	wget $(NEW_TEMPLATE) -O $(COMPONENTSDIR)/new.tsv
```

4. Add the component to the list of imports in `src/ontology/ubo-edit.owl`
5. Add the component to `src/ontology/catalog-v001.xml` (analogous to the breed one)
6. [Update the component](#update_component)

