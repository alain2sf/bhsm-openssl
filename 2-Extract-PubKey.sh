#!/opt/local/bin/bash
set -euo pipefail

# Dynamically locate the directory where calling sh lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the config file reliably using the absolute path
source "$SCRIPT_DIR/config.sh"

rm -f ${MLKEM_PK_PEM}

# token (label) = slot = ${SLOT_TOKEN}
# object = keypair = ${KEYPAIR_OBJ}

OPENSSL_CONF=${OPENSSL_CONF} \
OPENSSL_MODULES=${OPENSSL_MODULES} \
PKCS11_MODULE_PATH=${PKCS11_MODULE_PATH} \
BOUNCY_HSM_CFG_STRING=${BOUNCY_HSM_CFG_STRING} \
      openssl pkey -provider pkcs11prov -provider default \
                   -in "pkcs11:token=${SLOT_TOKEN};object=${KEYPAIR_OBJ};type=public" \
                   -pubin -pubout \
                   -out ${MLKEM_PK_PEM}

#openssl pkey -in ${MLKEM_PK_PEM} -pubin -text -noout

#EOF
