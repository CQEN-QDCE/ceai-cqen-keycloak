#!/bin/bash

# Vérifier si le dossier import n'est pas vide
if [ -d "./import" ] && [ "$(ls -A ./import)" ]; then
    # Copier le dossier import vers /tmp/import
    echo "Le dossier import est copié vrs /tmp/import"
    cp -r ./import /tmp/import
else
    echo "Le dossier import est vide ou n'existe pas, la copie est ignorée."
fi
