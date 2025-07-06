
#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# generate_ssl.sh — create a self-signed SSL cert for Nginx
#
# Usage:
#   DOMAIN_NAME=your.domain.com ./generate_ssl.sh
#
# Env vars:
#   DOMAIN_NAME   (required) domain for CN
#   SSL_DIR       (optional) output directory (default: /etc/nginx/ssl)
#   RSA_BITS      (optional) key size in bits (default: 2048)
#   DAYS_VALID    (optional) cert validity in days (default: 365)
# -----------------------------------------------------------------------------

# defaults
SSL_DIR="/etc/nginx/ssl"
RSA_BITS=2048
DAYS_VALID=365

# filenames
KEY="$SSL_DIR/inception.key"
CRT="$SSL_DIR/inception.crt"

echo "Creating SSL directory: $SSL_DIR"
mkdir -p "$SSL_DIR"

echo "Generating $RSA_BITS-bit private key at $KEY"
openssl genrsa -out "$KEY" "$RSA_BITS"

echo "Creating self-signed cert ($DAYS_VALID days) at $CRT"
openssl req -x509 -nodes \
    -newkey rsa:$RSA_BITS \
    -keyout "$KEY" \
    -out    "$CRT" \
    -days   "$DAYS_VALID" \
    -subj   "/CN=$DOMAIN_NAME"

echo "Done:
  • Key: $KEY
  • Cert: $CRT"

# hand off to whatever was passed in (i.e. CMD)
exec "$@"
