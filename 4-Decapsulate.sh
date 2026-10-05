#!/opt/local/bin/bash
set -euo pipefail

# Dynamically locate the directory where calling sh lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the config file reliably using the absolute path
source "$SCRIPT_DIR/config.sh"

rm -f "${RECEIVER_SECRET_FILE}"

# token (label) = slot = ${SLOT_TOKEN}
# object = keypair = ${KEYPAIR_OBJ}

OPENSSL_CONF="${OPENSSL_CONF}" \
OPENSSL_MODULES="${OPENSSL_MODULES}" \
PKCS11_MODULE_PATH="${PKCS11_MODULE_PATH}" \
BOUNCY_HSM_CFG_STRING="${BOUNCY_HSM_CFG_STRING}" \
  openssl pkeyutl \
     -decap -provider pkcs11prov -provider default \
     -inkey "pkcs11:token="${SLOT_TOKEN}";object="${KEYPAIR_OBJ}";type=private;pin-source="${PIN_FILE}"" \
     -in "${SENDER_CIPHERTEXT_FILE}" \
     -secret "${RECEIVER_SECRET_FILE}"

echo ""
echo "Shared secret: $(wc -c < "${RECEIVER_SECRET_FILE}") bytes"   # should be 32

#EOF
