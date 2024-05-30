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
Modules personnalisé qui ajoutent des fonctionalités à Keycloak.

### [Scripts](./scripts/)
Scripts d'automatisation et de tests pour interagir avec l'API d'administration de Keycloak.

### [Thèmes](./themes/)
Thèmes personnalisés pour l'interface utilisateur de Keycloak.

### [Utilitaires](./utils/)
Utilitaires pour supporter certaines fonctionnalités.

### Construction d'une image

1. Obtenir la dernière version git (git clone ou git pull).

```
git clone https://github.com/CQEN-QDCE/ceai-cqen-keycloak.git
```
1. Obtenir l'image keycloak en dev.

```
docker build -t keycloak_image:dev --build-arg ENV=dev .
```
1. Obtenir l'image keycloak en prod.

```
docker build -t keycloak_image:prod --build-arg ENV=prod .
```
1. Obtenir l'image keycloak upgrade.

```
docker build -t keycloak_image:upgrade .
```

## License

Le code contenu dans ce dépôt est sous la Licence Apache 2.0 sauf si mention contraire.

Référez-vous au fichier [LICENSE](LICENSE) pour plus de détails.

## Références

* https://github.com/keycloak/keycloak