#!/opt/local/bin/bash
set -euo pipefail

# Dynamically locate the directory where calling sh lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the config file reliably using the absolute path
source "$SCRIPT_DIR/config.sh"

echo -n "Comparing secrets..."

diff <(xxd -p -c 64 ${SENDER_SECRET_FILE}) <(xxd -p -c 64 ${RECEIVER_SECRET_FILE}) \
  && echo "Secrets MATCH" || { echo "Secrets MISMATCH"; exit 1; }

SECRET_HEX="$(xxd -p -c 64 ${SENDER_SECRET_FILE})"   # The 32-byte ML-KEM secret, as hex
KEY_ID_HEX="01"                                      # Arbitrary key identifier, must match on both ends

rm -f ${MSG_AES256_GCM}

echo -n "hello from the AES-256-GCM CMS demo" > ${MSG_AES256_GCM}

echo -n "Encrypting (AuthEnvelopedData, AES-256-GCM)..."

rm -f ${MSG_AES256_GCM_ENC}

openssl cms -encrypt \
  -in ${MSG_AES256_GCM} -out ${MSG_AES256_GCM_ENC} -outform DER \
  -aes-256-gcm \
  -secretkey "$SECRET_HEX" -secretkeyid "$KEY_ID_HEX" && echo "Done!"

echo -n "Decrypting..."

rm -f ${MSG_AES256_GCM_DEC}

openssl cms -decrypt \
  -in ${MSG_AES256_GCM_ENC} -out ${MSG_AES256_GCM_DEC} -inform DER \
  -secretkey "$SECRET_HEX" -secretkeyid "$KEY_ID_HEX" && echo "Done!"

echo -n "Comparing original and decrypted messages..."

diff ${MSG_AES256_GCM} ${MSG_AES256_GCM_DEC} && echo "Round-trip OK, authenticated AES-256-GCM"

echo ""
echo ""

echo "Inspecting the structure (confirms AuthEnvelopedData / GCM was actually used)..."
openssl cms -cmsout -in ${MSG_AES256_GCM_ENC} -inform DER -print | head -30 | grep "algorithm" | tail -1

#EOF
