# Realm-Deploy

Outils pour automatiser le déploiement de Keycloak avec un ou plusieurs Realms préconfiguré à partir de template.

## Fonctionnement

En utilisant les fichiers d'export JSON de realm Keycloak, on peut produire un "template" en retirant les secrets et remplaçants les informations qui changent d'un déploiement à l'autre par des variables.

Un script invoké par un fichier Dockerfile regénère les secrets et remplace les champs variables par les valeurs des arguments passé à la commande docker build.

Une image docker contenant un fichier JSON d'import de realm est alors produite et ce fichier d'import est chargé lors de l'instanciation de l'image.

## Procédure

À partir d'un conteneur docker contenant le realm nécéssaire au projet.

```bash
docker run -d --name keycloak -p 8080:8080 -e KEYCLOAK_USER=$KEYCLOAK_ADMIN_USER -e KEYCLOAK_PASSWORD=$KEYCLOAK_ADMIN_PASS quay.io/keycloak/keycloak 
```
Configurer le realm à l'aide de la console web.

### Export d'un realm 

Créer une image "snapshot" du conteneur contenant le realm configuré.
```bash
docker commit keycloak keycloak_snapshot
```
Arrêter le conteneur.
```bash
docker stop keycloak
```
Démarrer le conteneur "snapshot" avec un point de montage ouvert en écriture. Assurez-vous d'avoir un répertoire /tmp dans votre répertoire en cours $(pwd).
```bash
docker run -d -p 8080:8080 -e KEYCLOAK_USER=$KEYCLOAK_ADMIN_USER-e \
KEYCLOAK_PASSWORD=$KEYCLOAK_ADMIN_PASS -v $(pwd)/tmp:/tmp:z --name keycloak_snapshot -h keycloak  \
keycloak_snapshot
```
Lancer le script d'export sur le conteneur "snapshot". Dans l'exemple, on exporte le realm example vers le fichier tmp/example_realm.json
```bash
docker exec -it keycloak_snapshot /opt/jboss/keycloak/bin/standalone.sh -Djboss.socket.binding.port-offset=100 -Dkeycloak.migration.action=export -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.realmName=example -Dkeycloak.migration.usersExportStrategy=REALM_FILE -Dkeycloak.migration.file=/tmp/example_realm.json -Djboss.node.name=keycloak

```
Le fichier JSON du realm se trouve maintenant dans le répertoire /tmp (example_realm.json dans l'exemple) de votre répertoire en cours.

### Création du fichier "template"

Le fichier exporté doit être modifié en fichier "template" distribuable. Des variables au format ?NOMVARIABLE? doivent remplacer les informations variables d'une instance Keycloak à l'autre.

### Clés de cryptages

Tout d'abord les clés de cryptage doivent être retirées du fichier. Celle-ci seront régénérées par Keycloak lors de l'import. Celles-ci sont contenues dans la propriété "org.keycloak.keys.KeyProvider". 

Remplacer la valeur de la propriété par un tableau vide pour les retirer.

```json
"org.keycloak.keys.KeyProvider" : []
```

### Secrets

La regénérations des secrets est prise en charge par le script de remplacement. Tous les secrets au format uuid doivent être remplacé par la variable ?UUID?
```json
{
    "id" : "12345678-90ab-cdef-1234-567890abcdef",
    "clientId" : "dm-app",
    "name" : "Example Web Application",
    "rootUrl" : "?ROOTURL?",
    "adminUrl" : "",
    "baseUrl" : "/",
    "surrogateAuthRequired" : false,
    "enabled" : true,
    "alwaysDisplayInConsole" : false,
    "clientAuthenticatorType" : "client-secret",
    "secret" : "?UUID?",
    ...
}
```
### Champs variables 

Les autres champs variables doivent être remplacés par des variables de votre choix spécifiques à votre instance. Notez ces variables, elle devront être ajoutées au script de remplacement.
```json
"identityProviders" : [ {
    "alias" : "github",
    "internalId" : "12345678-90ab-cdef-1234-567890abcdef",
    "providerId" : "github",
    "enabled" : true,
    "updateProfileFirstLoginMode" : "on",
    "trustEmail" : false,
    "storeToken" : false,
    "addReadTokenRoleOnCreate" : false,
    "authenticateByDefault" : false,
    "linkOnly" : false,
    "firstBrokerLoginFlowAlias" : "first broker login",
    "config" : {
      "syncMode" : "IMPORT",
      "clientSecret" : "?GITHUBSECRET?",
      "clientId" : "?GITHUBID?",
      "useJwksUrl" : "true"
    }
  },
  ...
]
```

Les fichiers "template" doivent être placés dans le répertoire template avec l'extension .template.json.

### Édition du script de remplacement

Les variables inclues dans les templates doivent être ajouté au Dockerfile et au script realmconfig.sh.

### Dockerfile

Ajouter les variables comme "build argument" au Dockerfile et passer celles-ci au script realmconfig.sh.
```dockerfile
FROM quay.io/keycloak/keycloak:latest

#Add realm template vars as ARG here:
ARG ROOTURL
ARG GITHUBID
ARG GITHUBSECRET

...

#Pass your template VARS to realmconfig script:
RUN ./realmconfig.sh $ROOTURL $GITHUBID $GITHUBSECRET

```

### realmconfig.sh

Ajouter vos variables à la section de récupérations des arguments et à la boucle de remplacement.

```bash
#!/bin/bash

# Store the original IFS
OIFS="$IFS"
# Update the IFS to only include newline
IFS=$'\n'

#Test your custom vars here:

#?ROOTURL?
if [ ! "$1" ];
then read -p "Root Url: " ROOTURL
else ROOTURL=$1
fi

#?GITHUBID?
if [ ! "$2" ];
then read -p "Github Client ID: " GITHUBID
else GITHUBID=$2
fi

#?GITHUBSECRET?
if [ ! "$3" ];
then read -p "Github Client Secret: " GITHUBSECRET
else GITHUBSECRET=$3
fi

...
```
Certaines variables peuvent être générées par des outils. Assurez-vous que le conteneur contienne les outils nécéssaire.

Dockerfile:
```dockerfile
#Install uuidgen
RUN microdnf update -y && microdnf install -y util-linux
```
realmconfig.sh:
```bash
#Add generated or constant Custom vars

#?OTHER_UUID?
OTHER_UUID="$(uuidgen)"
```

Ajouter le remplacement des valeurs à la boucle de remplacement.
```bash
for REALMFILE in realms/*.template.json; do
    PRODREALMFILE="${REALMFILE%%.*}.json"

    while read -r LINE || [ -n "$LINE" ]; do

        ...

        #Add your custom vars swap here:

        #?ROOTURL?
        if [[ $LINE == *"?ROOTURL?"* ]]; then
            LINE=${LINE//\?ROOTURL\?/"${ROOTURL}"}
        fi

        #?GITHUBID?
        if [[ $LINE == *"?GITHUBID?"* ]]; then
            LINE=${LINE//\?GITHUBID\?/"${GITHUBID}"}
        fi

        #?GITHUBSECRET?
        if [[ $LINE == *"?GITHUBSECRET?"* ]]; then
            LINE=${LINE//\?GITHUBSECRET\?/"${GITHUBSECRET}"}
        fi

        #?OTHER_UUID?
        if [[ $LINE == *"?OTHER_UUID?"* ]]; then
            LINE=${LINE//\?OTHER_UUID\?/"${OTHER_UUID}"}
        fi

```

### Construire l'image keycloak

Passer les valeurs de remplacement comme build arguments.

```bash
docker build -t keycloak_example --build-arg=ROOTURL=http://localhost:3000 --build-arg=GITHUBID=123456ab123456ab12ab --build-arg=GITHUBSECRET=123456abcd123456789abcd123456789abcd12345 .
```

Le script de remplacement sera lancé lors du "build" et le fichier d'import du realm sera stocké dans l'image.

### Lancer l'import et le conteneur

Le conteneur peut maintenant être lancé. L'import du realm généré se produit sur l'instruction "ENTRYPOINT", il est donc important de ne pas écraser cette instruction en spécifiant des paramètres à la commande "docker run". Voir https://docs.docker.com/engine/reference/builder/#entrypoint

```bash
docker run -d --name keycloak_example -p 8080:8080 -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin keycloak_example
```