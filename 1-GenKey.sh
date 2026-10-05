#!/opt/local/bin/bash
set -euo pipefail

# Dynamically locate the directory where calling sh lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the config file reliably using the absolute path
source "$SCRIPT_DIR/config.sh"

# token (label) = slot = ${SLOT_TOKEN}
# object = keypair = ${KEYPAIR_OBJ}

OPENSSL_CONF="${OPENSSL_CONF}" \
OPENSSL_MODULES="${OPENSSL_MODULES}" \
PKCS11_MODULE_PATH="${PKCS11_MODULE_PATH}" \
BOUNCY_HSM_CFG_STRING="${BOUNCY_HSM_CFG_STRING}" \
        openssl genpkey -provider pkcs11prov -provider default -algorithm ML-KEM-768 \
                        -pkeyopt pkcs11_uri:"pkcs11:token="${SLOT_TOKEN}";object="${KEYPAIR_OBJ}";pin-source="${PIN_FILE}"" \
                        -out "pkcs11:token="${SLOT_TOKEN}";object="${KEYPAIR_OBJ}";pin-source="${PIN_FILE}""

#EOF
