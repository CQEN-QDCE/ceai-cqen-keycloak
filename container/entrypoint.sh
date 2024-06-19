#!/bin/bash

if [ -z "$ENV" ]; then
  ENV="upgrade"   
fi

echo "Environnement courant: $ENV"

if [ "$ENV" = "dev" ]; then
  exec /opt/keycloak/bin/kc.sh start-dev --spi-theme-static-max-age=-1 --spi-theme-cache-themes=false --spi-theme-cache-templates=false -Dkeycloak.password.blacklists.path=/opt/keycloak/data/password-blacklists --import-realm
elif [ "$ENV" = "prod" ]; then
  exec /opt/keycloak/bin/kc.sh start --spi-connections-jpa-quarkus-migration-strategy=update -Dkeycloak.password.blacklists.path=/opt/keycloak/data/password-blacklists --import-realm --optimized
elif [ "$ENV" = "upgrade" ]; then
  exec /opt/keycloak/bin/kc.sh start --spi-connections-jpa-quarkus-migration-strategy=update -Dkeycloak.password.blacklists.path=/opt/keycloak/data/password-blacklists --optimized
else
  echo "Environnement inconnu: $ENV"
  exit 1
fi
