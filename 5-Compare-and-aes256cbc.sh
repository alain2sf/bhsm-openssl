#!/opt/local/bin/bash
set -euo pipefail

# Dynamically locate the directory where calling sh lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the config file reliably using the absolute path
source "$SCRIPT_DIR/config.sh"

echo -n "Comparing secrets..."

diff <(xxd -p -c 64 ${SENDER_SECRET_FILE}) <(xxd -p -c 64 ${RECEIVER_SECRET_FILE}) \
  && echo "Secrets MATCH" || { echo "Secrets MISMATCH"; exit 1; }

echo -n "Generating IV..."

rm -f ${MSG_AES256_CBC_IV}

# Generate and save the IV once, alongside your ML-KEM-derived key
IV=$(openssl rand -hex 16)
echo "$IV" > ${MSG_AES256_CBC_IV} && echo "Done!"

rm -f ${MSG_AES256_CBC}

echo -n "hello from the AES-256-CBC demo" > ${MSG_AES256_CBC}

echo -n "encrypting..."

rm -f ${MSG_AES256_CBC_ENC}

openssl enc -aes-256-cbc \
  -K "$(xxd -p -c 64 ${SENDER_SECRET_FILE})" \
  -iv "$IV" \
  -in ${MSG_AES256_CBC} -out ${MSG_AES256_CBC_ENC} && echo "Done!"

echo -n "decrypting..."

rm -f ${MSG_AES256_CBC_DEC}

openssl enc -d -aes-256-cbc \
  -K "$(xxd -p -c 64 ${RECEIVER_SECRET_FILE})" \
  -iv "$(cat ${MSG_AES256_CBC_IV})" \
  -in ${MSG_AES256_CBC_ENC} -out ${MSG_AES256_CBC_DEC} && echo "Done!"

echo -n "Comparing original and decrypted messages..."

diff ${MSG_AES256_CBC} ${MSG_AES256_CBC_DEC} && echo "Round-trip OK"

#EOF
