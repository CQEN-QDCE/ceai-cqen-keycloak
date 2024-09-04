HOMEPAGE_URL=${HOMEPAGE_URL:-http://localhost:8080}
TIMEOUT=${TIMEOUT:-60}  # Temps maximum d'attente en secondes
INTERVAL=${INTERVAL:-5}  # Intervalle entre les vérifications en secondes

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