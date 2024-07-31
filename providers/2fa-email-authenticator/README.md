# 🔒 Keycloak 2FA Email Authenticator

Implémentation du fournisseur(provider) d'authentification Keycloak permet d'obtenir une authentification à deux facteurs avec un OTP/code/token envoyé par e-mail (via SMTP)

Lors de la connexion avec ce fournisseur, vous pouvez envoyer un code de vérification (otp) à l'adresse e-mail de l'utilisateur.

# 🚀 Déploiement

## Provider

L'exécution de `mvn package` permet d'obtenir un fichier jar (2fa-email-authenticator.jar). Ce fichier sera copié dans le container a partir du fichier le Dockerfile.

## Thèmes

**email-code-form.ftl** le fotmulaire de saisie du code est copié dans le theme cqen vers /themes/cqen/login

**html/code-email.ftl** le fichier html est copié dans le theme cqen vers /themes/cqen/email/html

**text/code-email.ftl** le contenu du courriel est copié dans le theme cqen vers /themes/cqen/email/text

**messages/*.properties** les messages sont copiés dans le theme cqen vers /themes/cqen/email/messages/ et themes/cqen/login/messages/


# Configurations

## Configuration du courriel
Configuré les paramètres de courriel pour le royaume

## Flux d'authentification
Créer un nouveau flux d'authentification  et ajouter le founisseur Courriel OTP.