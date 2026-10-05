#!/opt/local/bin/bash
set -euo pipefail

# Dynamically locate the directory where calling sh lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the config file reliably using the absolute path
source "$SCRIPT_DIR/config.sh"

rm -f ${SENDER_SECRET_FILE}
rm -f ${SENDER_CIPHERTEXT_FILE}

openssl pkeyutl -encap \
                -inkey ${MLKEM_PK_PEM} -pubin \
                -secret ${SENDER_SECRET_FILE} \
                -out ${SENDER_CIPHERTEXT_FILE}

echo "Ciphertext   : $(wc -c < ${SENDER_CIPHERTEXT_FILE}) bytes"
echo "Shared secret: $(wc -c < ${SENDER_SECRET_FILE}) bytes"   # should be 32

#EOF
