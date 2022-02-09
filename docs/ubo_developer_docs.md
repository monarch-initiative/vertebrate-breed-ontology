# UBO Developer Docs

## How to refresh components

### Refreshing ROBOT templates from Google Sheets:

```
cd src/ontology
sh run.sh make sync_google_sheets
```

This will download the Google sheets as TSV and store them in the `components` directory.

### Updating components

```
cd src/ontology
sh run.sh make components/breeds.owl
```

This will refresh the breeds component based on the current ROBOT template stored in components/breeds.tsv.

Note: The component will not update unless the content of the google sheet or the ubo-edit file has changed. To "force" the update, add `-B` at the end of the command. For example: 
`sh run.sh make components/breeds.owl -B`

## Adding entirely new components:

- Add the name of the component to `src/ontology/ubo-odk.yaml` (in the `components/products` section, like `breeds.owl`).
- Run `sh run.sh make update_repo`
- Add the component to the `sync_google_sheets` `make` commmand in `ubo.Makefile`, essentially:
   - creating a new variable for it (like `BREED_TEMPLATE`)
   - adding a wget command underneat the one that is currrently there.

```
sync_google_sheets:
	wget $(BREED_TEMPLATE) -O $(COMPONENTSDIR)/breeds.tsv
	wget $(NEW_TEMPLATE) -O $(COMPONENTSDIR)/new.tsv
```

- Add the component to the list of imports in `src/ontology/ubo-edit.owl`
- Add the component to `src/ontology/catalog-v001.xml` (analogous to the breed one)
- [Update the component](#updating-components)

