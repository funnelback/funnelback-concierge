#!/bin/bash
# Post index workflow script

# Allow the collection.cfg variables to be passed in and made available within this script.
# Pass the variables in as -c $COLLECTION_NAME -g $GROOVY_COMMAND -v $CURRENT_VIEW -p <comma separated list of profiles>
while getopts ":c:g:v:p:" opt; do
  case $opt in
    c) COLLECTION_NAME="$OPTARG"
    ;;
    g) GROOVY_COMMAND="$OPTARG"
    ;;
    v) CURRENT_VIEW="$OPTARG"
    ;;
    p) PROFILES="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# Genetate autocompletion for each profile

IFS=',' read -r -a PROFILE <<< ${PROFILES}

for p in "${PROFILE[@]}"
do
        # Run the Funnelback query to return the CSV, catching any errors.
        echo "Generating autocompletion CSV for $p"
        curl --connect-timeout 60 --retry 3 --retry-delay 20 'http://localhost/s/search.html?collection='$COLLECTION_NAME'&query=!generate_autoc&profile='$p'&form=auto-completion&view='$CURRENT_VIEW'' -o $SEARCH_HOME/conf/$COLLECTION_NAME/$p/auto-completion.csv || exit 1
        # Build auto-completion using the generated auto-completion.csv
$SEARCH_HOME/bin/build_autoc $SEARCH_HOME/data/$COLLECTION_NAME/$CURRENT_VIEW/idx/index $SEARCH_HOME/conf/$COLLECTION_NAME/$p/auto-completion.csv -collection $COLLECTION_NAME -profile $p

done
