# Ontology release

VBO is released on a monthly basis around the first of the month. All VBO releases are available [here](https://github.com/monarch-initiative/vertebrate-breed-ontology/releases).  

Please note that this document was created for editor's convenience when creating a new release. Detailed description of ontology release process has been reported elsewhere (for example [here](https://oboacademy.github.io/obook/tutorial/managing-ontology-releases-odk/) and [here](http://pato-ontology.github.io/pato/odk-workflows/ReleaseWorkflow/)).

VBO release is done using ODK, and includes
 1. Update Imports and Components
 1. Run a release using ODK
 1. Merge the release
 1. Create a GitHub release  

Notes:  
    - All the commands should be done in the Terminal, from the folder `vertebrate-breed-ontology/src/ontology`  
    - You must have [docker installed](http://pato-ontology.github.io/pato/odk-workflows/SettingUpDockerForODK/)

## Update Imports and Components
1. Update imports using the command:  
`sh run.sh make refresh-imports`  
This will refresh ALL the imports.

1. Update components (see details [here](https://monarch-initiative.github.io/vertebrate-breed-ontology/components))
  ```
  sh run.sh make sync_google_sheets  
  sh run.sh make recreate-components
  ```
1. Create a PR, wait for the QC checks to pass, and merge to Master.


## Run the release
**Before starting the release**
  - Make sure that all the pull requests are merged into the master branch.
  - Make sure you have the latest ODK installed by running `docker pull obolibrary/odkfull`
  - Create a new branch (e.g. `release-YYYY-MM-DD`)

**Running the release**
  1. Run: `sh run.sh make prepare_release IMP=false -B`
    Note: `IMP=false` means that we are running the release without updated the imports (we updated them in the previous step)
  1. Review the release: check that changes made in the ontology can be found in the new vbo.owl  
  1. If changes are as expected, create a PR
  1. Once the QC checks have successfully passed, merge to Master

## Create a GitHub release
1. Go to [https://github.com/monarch-initiative/vertebrate-breed-ontology/releases](https://github.com/monarch-initiative/vertebrate-breed-ontology/releases)
1. Click "Draft new release"
1. Click "Choose a tag".
    - Format for tag version should be : vYYYY-MM-DD (ie date prefixed with a v)
    - The tag version must be the date on which the ontology was built.
1. Write the release title: for VBO, we use the same name as the tag: for example v2023-01-01
1. Write a description *(conventions for VBO are TBD)*
1. Click "Publish release"

You are done! Congratulations!
