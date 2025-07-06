FROM debian:bullseye

EXPOSE 443

# Définir l'argument pour le domaine avec une valeur par défaut
ARG DOMAIN_NAME=jeportie.42.fr

RUN apt-get update && apt-get install -y nginx openssl
COPY conf/nginx.conf /etc/nginx/sites-enabled/default

# @command openssl : utilitaire de chiffrement pour SSL/TLS
# @command req : sous-commande d’OpenSSL pour gérer les certificats et CSR
#   $@flag -x509 : génère directement un certificat auto-signé (sans CSR séparé)
#   $@flag -nodes : n’applique pas de passphrase sur la clé privée
#   $@flag -days : définit la durée de validité du certificat
#     @param 365 : certificat valable 365 jours
#   $@flag -newkey : crée une nouvelle paire de clés
#     @param rsa:2048 : algorithme RSA, clé de 2048 bits
#   $@flag -keyout : chemin de sortie pour la clé privée
#     @param /etc/nginx/ssl/inception.key : fichier de clé privée
#   $@flag -out : chemin de sortie pour le certificat
#     @param /etc/nginx/ssl/inception.crt : fichier de certificat auto-signé
#   $@flag -subj : fournit les champs de sujet en une seule chaîne, sans invite
#     @param "/CN=${DOMAIN_NAME}" : Common Name = nom de domaine cible
RUN mkdir -p /etc/nginx/ssl && \
	openssl req -x509 -nodes -days 365 \
	-newkey rsa:2048 -keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/CN=${DOMAIN_NAME}"

CMD ["nginx", "-g", "daemon off;"]
