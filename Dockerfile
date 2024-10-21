# Définition de la version de Keycloak à utiliser comme argument pour être réutilisable dans le Dockerfile
ARG IMG_VERSION=26.0.1
ARG ENV=upgrade

# Utilisation de Red Hat Universal Base Image 9 comme image de base pour le pré-build
FROM registry.access.redhat.com/ubi9 as ubi-micro-build
# Création d'un système de fichiers racine pour les installations
RUN mkdir -p /mnt/rootfs
# Installation de util-linux et curl-minimal dans le système de fichiers racine, sans documentation pour réduire la taille
RUN dnf install --installroot /mnt/rootfs util-linux curl-minimal --releasever 9 --setopt install_weak_deps=false --nodocs -y && \
    dnf --installroot /mnt/rootfs clean all && \
    rpm --root /mnt/rootfs -e --nodeps setup

# Construction des modules de Keycloak
FROM docker.io/maven:3-amazoncorretto-17 as providers-builder

COPY ./providers ./providers

# Construction du module 2fa-email-authenticator
RUN mvn -f ./providers/2fa-email-authenticator/pom.xml clean package
# Ajouter les nouveaux modules ici

# Construction optimisée de l'exécutable Keycloak
FROM quay.io/keycloak/keycloak:${IMG_VERSION} as builder
ARG IMG_VERSION
ARG ENV

# Copie du système de fichiers racine préparé dans l'étape précédente
COPY --from=ubi-micro-build /mnt/rootfs /

# Configuration des variables d'environnement pour Keycloak
ENV KC_DB=postgres
ENV ENV=${ENV}


# Configuration du répertoire de travail pour l'importation des configurations de realm (non utilisé dans migration)
WORKDIR /tmp/realmconfig
COPY --chown=1000 container/realms ./realms
COPY --chown=1000 container/realmconfig.sh .

# Exécution du script de configuration de realm avec les variables d'environnement passées
RUN ./realmconfig.sh

# Copie des providers personnalisés dans le répertoire des providers de Keycloak (non utilisé dans migration)
COPY --from=providers-builder --chown=1000 providers/2fa-email-authenticator/target/*.jar /opt/keycloak/providers

# Retour au répertoire de travail de Keycloak
WORKDIR /opt/keycloak

# Construction du serveur Keycloak avec les configurations et providers précédemment ajoutés
RUN /opt/keycloak/bin/kc.sh build --health-enabled=true

# Étape finale de création de l'image Keycloak
FROM quay.io/keycloak/keycloak:${IMG_VERSION} as keycloak
ARG IMG_VERSION
ARG ENV

# Copie du système de fichiers racine de l'étape de pré-build
COPY --from=ubi-micro-build /mnt/rootfs /

# Copie de l'ensemble du répertoire de Keycloak depuis l'étape de construction
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Copie des realms importés et d'autres configurations dans le répertoire de données de Keycloak (non utilisé dans migration)
COPY --from=builder /tmp/realmconfig/realms /opt/keycloak/data/import

# Copie des fichiers de thème personnalisés
COPY --chown=1000 ./themes/cqen /opt/keycloak/themes/cqen

# Copie des listes noires de mots de passe
COPY --chown=1000 ./utils/password-blacklists /opt/keycloak/data/password-blacklists

# Copier le script de point d'entrée
COPY --chown=1000 container/entrypoint.sh /opt/keycloak/entrypoint.sh

# Définir le point d'entrée
ENTRYPOINT ["/opt/keycloak/entrypoint.sh"]
