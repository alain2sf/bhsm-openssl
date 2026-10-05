#!/opt/local/bin/bash
set -euo pipefail

# Dynamically locate the directory where calling sh lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the config file reliably using the absolute path
source "$SCRIPT_DIR/config.sh"

rm -f ${MLKEM_PK_PEM}
rm -f ${SENDER_SECRET_FILE} ${SENDER_CIPHERTEXT_FILE}
rm -f ${RECEIVER_SECRET_FILE}

rm -f ${MSG_AES256_CBC} ${MSG_AES256_CBC_IV} ${MSG_AES256_CBC_ENC} ${MSG_AES256_CBC_DEC}
rm -f ${MSG_AES256_GCM} ${MSG_AES256_GCM_ENC} ${MSG_AES256_GCM_DEC}

#EOF