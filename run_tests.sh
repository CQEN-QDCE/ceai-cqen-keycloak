#!/bin/bash

# Variables
DOCKER_COMPOSE_FILE="docker-compose-dev.yml"
DOCKER_IMAGE_NAME="ceai-cqen-keycloak:latest"
REALM_TEMPLATE_FILE="ceai-realm.template.json"
KEYCLOAK_URL="http://localhost:8080/realms/master"

# Fonction pour exécuter une commande et vérifier le code de retour
run_command() {
  "$@"
  local status=$?
  if [ $status -ne 0 ]; then
    echo "Error with command: $1" >&2
    exit 1
  fi
  return $status
}
# Copier le fichier ceai-realm.template.json du répertoire tests vers le répertoire container/realms
run_command cp tests/$REALM_TEMPLATE_FILE container/realms/

# Copier le fichier .env dans le répertoire courant
run_command cp tests/.env .


# Construire et démarrer les conteneurs Docker avec les variables d'environnement
run_command docker-compose --env-file .env -f $DOCKER_COMPOSE_FILE build
run_command docker-compose --env-file .env -f $DOCKER_COMPOSE_FILE up -d

# Attendre que Keycloak soit complètement démarré en utilisant un healthcheck
echo "Waiting for Keycloak to start..."
while ! curl -s $KEYCLOAK_URL > /dev/null; do
  echo "Waiting for Keycloak to be available..."
  sleep 5
done

echo "Keycloak is up and running!"

# Exécuter les tests
run_command python3 tests/test_keycloak.py

# Arrêter et supprimer les conteneurs Docker
run_command docker-compose --env-file .env -f $DOCKER_COMPOSE_FILE down

# Supprimer les fichiers .env et ceai-realm.template.json copiés
rm .env
rm container/realms/ceai-realm.template.json


echo "Tests completed successfully and project directory removed."