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

# Port de gestion

Le port de gestion (management port) dans Keycloak est utilisé pour des opérations spécifiques d'administration, comme le suivi de l'état, la gestion des clusters ou l'obtention de métriques, mais il ne donne pas directement accès à la console d'administration graphique de Keycloak.

## Accès à partir du port de gestion 

Le port de gestion permet de séparer les requêtes utilisateurs ordinaires (par exemple, celles qui concernent l'authentification et l'autorisation des utilisateurs) des opérations administratives et de gestion, comme :

Le monitoring de l'état de santé de Keycloak.
Le redémarrage ou le rechargement de configurations.
L'activation ou la désactivation de certaines fonctionnalités en cours d'exécution.

Le port de gestion, souvent différent du port principal de l'interface utilisateur, est utilisé pour des requêtes REST liées à la gestion du serveur Keycloak. Voici un exemple de comment interagir avec le port de gestion via l'API REST pour obtenir des informations sur le serveur.

## Exposer les Ports avec Docker

Lorsque vous lancez Keycloak avec Docker, vous pouvez spécifier plusieurs ports pour que Keycloak écoute à la fois pour les utilisateurs et pour les administrateurs. En général :

Le port par défaut pour le serveur HTTP Keycloak est 8080.
Le port de gestion peut être configuré sur 9000.

## Exemple de commande curl pour interagir avec le port de gestion :

Démarrer le conteneur de développement en spécifiant un port de gestion:

```
docker run -p 8080:8080 -p 9000:9000 -e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin -e ENV=dev -e KC_HTTP_MANAGEMENT_PORT=9000 -e KC_HEALTH_ENABLED=true -e KC_METRICS_ENABLED=true keycloak_image:dev start-dev
```

Vous pouvez utiliser les commandes suivantes pour interroger l'état du serveur et l'obtention de métriques :

```
curl http://localhost:9000/health

curl http://localhost:9000/metrics
```

Ces requêtes vous retournerons les informations sur la santé du serveur keycloak et les métriques via le port de gestion.

Cependant, pour accéder à la console d'administration complète, vous devrez utiliser le port principal (8080) et non le port de gestion. Le port de gestion n'est pas conçu pour l'accès à l'interface graphique de gestion de Keycloak, mais pour des opérations automatisées via API.

Pour avoir accès a la console administration, vous devez utiliser l'URL:

```
http://localhost:8080
```



# Variables d'environnement

| Nom                           | Description                                                   |
| ----------------------------  | ------------------------------------------------------------- |
| `KC_BOOTSTRAP_ADMIN_USERNAME`              | Nom d'utilisateur administrateur initial                                 |
| `KC_BOOTSTRAP_ADMIN_PASSWORD`     | Mot de passe administrateur initial
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


## License

Le code contenu dans ce dépôt est sous la Licence Apache 2.0 sauf si mention contraire.

Référez-vous au fichier [LICENSE](LICENSE) pour plus de détails.

## Références

* https://github.com/keycloak/keycloak