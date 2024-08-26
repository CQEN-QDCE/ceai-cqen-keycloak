<!-- ENTETE -->
[![img](https://img.shields.io/badge/Cycle%20de%20Vie-Phase%20D%C3%A9couverte-339999)](https://www.quebec.ca/gouv/politiques-orientations/vitrine-numeriqc/accompagnement-des-organismes-publics/demarche-conception-services-numeriques)
[![License](https://img.shields.io/badge/Licence-Apache_2.0-blue)](LICENSE)
---
![Logo MCN](https://github.com/CQEN-QDCE/.github/blob/main/images/mcn.png?raw=true)
<!-- FIN ENTETE -->

<!-- PROJET -->
# Utilitaires Keycloak

Répertoire d'utilitaires pour faciliter le déploiement et l'utilisation de Keycloak dans le laboratoire d'innovation du centre d'expertise appliquée en innovation du CQEN.

## Contenu du dépôt

### [Conteneurs](./container)
Dockerfile et script docker-compose pour déployer Keycloak avec les utilitaires du dépôt.

### [*Providers*](./providers/)
Modules personnalisé qui ajoutent des fonctionnalités à Keycloak.

### [Scripts](./scripts/)
Scripts d'automatisation et de tests pour interagir avec l'API d'administration de Keycloak.

### [Thèmes](./themes/)
Thèmes personnalisés pour l'interface utilisateur de Keycloak.

### [Utilitaires](./utils/)
Utilitaires pour supporter certaines fonctionnalités.

## Construction d'une image

1. Obtenir la dernière version git (git clone ou git pull).

```
git clone https://github.com/CQEN-QDCE/ceai-cqen-keycloak.git
```
2. Obtenir l'image keycloak en dev.

```
docker build -t keycloak_image:dev --build-arg ENV=dev .
```
3. Obtenir l'image keycloak en prod.

```
docker build -t keycloak_image:prod --build-arg ENV=prod .
```
4. Obtenir l'image keycloak upgrade.

```
docker build -t keycloak_image:upgrade .
```

## Variables d'environnement

| Nom                           | Description                                                   |
| ----------------------------  | ------------------------------------------------------------- |
| `KEYCLOAK_ADMIN`              | Nom d'utilisateur administrateur initial                                 |
| `KEYCLOAK_ADMIN_PASSWORD`     | Mot de passe administrateur initial
| `KC_DB`                       | Le fournisseur de base de données..
| `KC_DB_URL`                   | L'URL JDBC complète de la base de données.
| `KC_HOSTNAME`                 | Adresse à laquelle le serveur est exposé.
| `KC_HTTP_RELATIVE_PATH`       | le chemin relatif aux ressources à servir. Le chemin doit commencer par un /.
| `KC_DB_USERNAME`              | Le nom d'utilisateur de l'utilisateur de la base de données. 
| `KC_DB_PASSWORD`              | Le mot de passe de l'utilisateur de la base de données.
| `KC_METRICS_ENABLED`          | Si le serveur doit exposer des métriques.
| `KC_HEALTH_ENABLED`           | Si le serveur doit exposer des points de terminaison de contrôle de santé.
| `KC_PROXY_HEADERS`            | Les en-têtes proxy qui doivent être acceptés par le serveur.
| `KC_HTTP_MANAGEMENT_PORT`     | Port de l'interface de gestion.
| `KC_HTTP_ENABLED`             | Active l'écouteur HTTP.
| `KC_FEATURES`                 | Active un ensemble d'une ou plusieurs fonctionnalités.
| `KC_HTTP_MANAGEMENT_RELATIVE_PATH` | Le chemin relatif pour la diffusion des ressources à partir de l'interface de gestion.


## NB:

A partir de keycloak version 25, si nous ne souhaitons pas utiliser le port de gestion  9000, nous devons ajouter dans le Dockerfile la variable d'environnement KC_LEGACY_OBSERVABILITY_INTERFACE=true.

Si par contre nous souhaitons pas utiliser le port de gestion 9000, nous devons enlever du Dockerfile la variable d'environnement KC_LEGACY_OBSERVABILITY_INTERFACE ou la mettre a false, nous devous également ajouter dans le Dockerfile les variables d'environnement KC_HTTP_MANAGEMENT_PORT=9000 et KC_HTTP_MANAGEMENT_RELATIVE_PATH=/ puis ajuster le docker-compose.

## License

Le code contenu dans ce dépôt est sous la Licence Apache 2.0 sauf si mention contraire.

Référez-vous au fichier [LICENSE](LICENSE) pour plus de détails.

## Références

* https://github.com/keycloak/keycloak