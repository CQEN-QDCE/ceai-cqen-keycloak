#!/bin/bash

# Variables
DOCKER_COMPOSE_FILE="docker-compose-dev.yml"
REALM_TEMPLATE_FILE="ceai-realm.template.json"
HOMEPAGE_URL=${HOMEPAGE_URL:-http://localhost:8080}
TIMEOUT=${TIMEOUT:-60}  # Temps maximum d'attente en secondes
INTERVAL=${INTERVAL:-5}  # Intervalle entre les vérifications en secondes

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
# run_command cp tests/.env .

# Construire et démarrer les conteneurs Docker avec les variables d'environnement
run_command docker-compose --env-file .env -f $DOCKER_COMPOSE_FILE build
run_command docker-compose --env-file .env -f $DOCKER_COMPOSE_FILE up -d

# Attendre que Keycloak soit complètement démarré
echo "Waiting for Keycloak to start..."

# Initialiser le compteur de temps
elapsed=0

# Boucle jusqu'à ce que le code de retour HTTP soit 200 ou que le temps maximum soit atteint
while true; do
  HTTP_CODE=$(curl -s -L -o /dev/null -w '%{http_code}' $HOMEPAGE_URL)
  
  if [ "$HTTP_CODE" = "200" ]; then
    echo "Keycloak is ready! (HTTP code: $HTTP_CODE)"
    break
  fi

  if [ $elapsed -ge $TIMEOUT ]; then
    echo "Keycloak did not become available within $TIMEOUT seconds. Exiting... (last HTTP code: $HTTP_CODE)"
    exit 1
  fi

  echo "Waiting for Keycloak to be available... (HTTP code: $HTTP_CODE)"
  sleep $INTERVAL
  elapsed=$((elapsed + INTERVAL))
done
