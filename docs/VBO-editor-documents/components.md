# Ontology components

An ontology can include information external to the actual ontology, such as "imports" and "components" (more details [here](https://obofoundry.org/COB/odk-workflows/RepositoryFileStructure/#Components)). **Imports** represent subsets of external ontologies that are re-used in the ontology (e.g. COB, RO, OMO are ontologies imported into VBO). **Components** are part of the ontology but are managed/maintained outside of the ontology; for example, a component is a part of the ontology managed in ROBOT templates.

VBO was created such that it is managed in ROBOT templates, ie the source of truth for VBO terms (id, labels, synonyms,etc) is ROBOT templates maintained in google sheets. The ontology editing is done in these ROBOT templates; the ontology is then updated by a process refreshing the components.

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

To update ALL the components, use the command: `sh run.sh make recreate-components`

Note: The component will not update unless the content of the google sheet or the vbo-edit file has changed. To "force" the update, add `-B` at the end of the command. For example:
`sh run.sh make components/breeds.owl -B`

## Adding entirely new components:

- Add the name of the component to `src/ontology/vbo-odk.yaml` (in the `components/products` section, like `breeds.owl`).
- Run `sh run.sh make update_repo`
- Add the component to the `sync_google_sheets` `make` commmand in `vbo.Makefile`, essentially:
   - creating a new variable for it (like `BREED_TEMPLATE`)
   - adding a wget command underneat the one that is currrently there.

```
sync_google_sheets:
	wget $(BREED_TEMPLATE) -O $(COMPONENTSDIR)/breeds.tsv
	wget $(NEW_TEMPLATE) -O $(COMPONENTSDIR)/new.tsv
```

- Add the component to the list of imports in `src/ontology/vbo-edit.owl`
- Add the component to `src/ontology/catalog-v001.xml` (analogous to the breed one)
- [Update the component](#updating-components)

