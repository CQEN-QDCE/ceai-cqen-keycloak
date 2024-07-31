#!/bin/bash

# Store the original IFS
OIFS="$IFS"
# Update the IFS to only include newline
IFS=$'\n'

#Test your custom vars here:


#Add generated or constant Custom vars

#COMMAND_RESULT="$(command)"

for REALMFILE in realms/*.template.json; do
    PRODREALMFILE="${REALMFILE%%.*}.json"

    while read -r LINE || [ -n "$LINE" ]; do
        
        #Secret Regeneration
        #?UUID?
        if [[ $LINE == *"?UUID?"* ]]; then
            LINE=${LINE//\?UUID\?/"$(uuidgen)"}
        fi

        #Add your custom vars swap here:

        #?COMMAND_RESULT?
        #if [[ $LINE == *"?COMMAND_RESULT?"* ]]; then
        #    LINE=${LINE//\?COMMAND_RESULT\?/"${COMMAND_RESULT}"}
        #fi

        echo $LINE
    done < "${REALMFILE}" > "${PRODREALMFILE}"

    rm "${REALMFILE}"
done

# Reset IFS
IFS="$OIFS"