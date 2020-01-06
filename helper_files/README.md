# Helper files

The following helper files can be used to generate autocompletion CSV from the index.

* **auto-completion-master.ftl:** Freemarker template to produce auto-completion CSV.
* **auto-completion.ftl:** Freemarker template to share the master template between profiles.
* **hook\_post\_process.groovy:** Groovy script (required by Freemarker template) to inject stop words into the data model.
* **post\_index.sh:** Post index workflow script to generate auto-completion when the collection updates.

# Limitations:

* The Freemarker template currently only supports URL and query actions, sourced from the document's URL. 

# Usage instructions

### Step 1: Create profiles for each auto-completion source

* Copy the auto-completion-master.ftl to the _default and _default_preview profiles for the collection
* Copy the auto-completion.ftl to the each new profile folder (both live and preview)
* Create a padre_opts.cfg with appropriate profile scoping and optimisation.  Include -SM=meta and -SF=[LIST OF METADATA FIELDS] if you wish to display any metadata in your auto completion.

	Something similar to the following:

	```
	-gscope1=3 -SM=off -log=false -num_ranks=1000 -vsimple=true
	```
* Configure the triggers in collection.cfg by adding the a ```auto-completion.PROFILENAME.triggers``` field for each profile.  The triggers list is a comma separated list of compound triggers.  A single compound trigger can be made up of more than one field.  Note: ensure you handle error cases by setting a default value for any Freemarker variable that may be null.

	e.g. a person autocompletion might have 4 triggers based on first/last name, last/first name, department and the page title.

	```
	auto-completion.people.triggers=s.result.metaData["firstName"]! s.result.metaData["lastName"]!,s.result.metaData["lastName"]! s.result.metaData["firstName"]!,s.result.metaData["department"]!,s.result.title
	```
* If the result does not have a URL configure the action mode.  Supported values are "Q": execute the trigger as a query; "U": redirect to the value contained in the ClickUrl

	e.g. use the trigger running as a query for the action.

	```
	auto-completion.people.action-mode=Q
	```

### Step 2: Copy the post process hook script to the collection

* The ```hook_post_process.groovy``` script should be copied to the collection's configuration folder.  Note: if the file already exists then the new hook script needs to be merged with the existing script.

### Step 3: Add the workflow script

* The ```post_index.sh``` script should be copied to a ```@workflow``` folder under the collection's configuration folder.
* Note: the post index script will need to have the curl command updated if Funnelback is not running on port 80 (eg. if Funnelback runs on port 8080 then update the command to access http://localhost:8080 instead of http://localhost).
* Add a workflow command to collection.cfg

	```
	post_index_command=$SEARCH_HOME/conf/$COLLECTION_NAME/@workflow/post_index.sh -c $COLLECTION_NAME -v $CURRENT_VIEW -p <comma separated list of profiles>
	```

	The comma-separated list of profiles should be the live profiles that auto-completion should be generated for.  e.g. ```-p staff,courses,news```

* Update the permission of the shell script to ensure that the search user can execute the script.  e.g. ```chmod 775 $SEARCH_HOME/conf/COLLECTION/@workflow/post_index.sh```
* Test the workflow command by running it on the command line.

### Step 4: Update the collection

* Run an update of the collection (note: a reindex of the live view should be sufficient if the collection is already built).

### Step 5: Configure concierge JavaScript

* Add the new sources to autocompletion.
* Each new source can be added to concierge by defining a new data source that uses the correct collection and profile.  The results can be templated from the same datasource configuration and all the metadata that was defined in padre\_opts should be available to use in the template.

