#!/bin/bash

echo "Environnement courrant: $ENV"

if [ -z "$ENV" ]; then
  echo "la variable ENV n'est pas définie."
  exit 1
fi

if [ "$ENV" = "dev" ]; then
  exec /opt/keycloak/bin/kc.sh start-dev --spi-theme-static-max-age=-1 --spi-theme-cache-themes=false --spi-theme-cache-templates=false -Dkeycloak.password.blacklists.path=/opt/keycloak/data/password-blacklists --import-realm
elif [ "$ENV" = "prod" ]; then
  exec /opt/keycloak/bin/kc.sh start --spi-connections-jpa-quarkus-migration-strategy=update -Dkeycloak.password.blacklists.path=/opt/keycloak/data/password-blacklists --import-realm --optimized
elif [ "$ENV" = "upgrade" ]; then
  exec /opt/keycloak/bin/kc.sh start --spi-connections-jpa-quarkus-migration-strategy=update -Dkeycloak.password.blacklists.path=/opt/keycloak/data/password-blacklists --optimized
elif [ "$ENV" = "migration" ]; then
  exec /opt/keycloak/bin/kc.sh start --spi-connections-jpa-quarkus-migration-strategy=update -Dkeycloak.migration.action=import -Dkeycloak.migration.provider=dir -Dkeycloak.migration.dir=/tmp/import -Dkeycloak.password.blacklists.path=/opt/keycloak/data/password-blacklists --optimized
else
  echo "Environnement inconnu: $ENV"
  exit 1
fi
