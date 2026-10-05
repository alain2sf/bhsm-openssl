#!/opt/local/bin/bash
set -euo pipefail

# Dynamically locate the directory where calling sh lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKIP_PIN_CREATE=1    # Don't re-create the PIN file

# Source the config file reliably using the absolute path
source "$SCRIPT_DIR/config.sh"

OPENSSL_CONF=${OPENSSL_CONF} \
OPENSSL_MODULES=${OPENSSL_MODULES} \
      openssl list -providers -verbose -provider pkcs11prov

#EOF
