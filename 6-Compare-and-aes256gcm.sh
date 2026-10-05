#!/opt/local/bin/bash
set -euo pipefail

# HKDF-SHA256: derive a 32-byte key (64 hex chars) from a KEM shared secret.
# Usage: derive_key <secret-file> <context-label>
# The context label gives domain separation: CBC and GCM get different keys.
#
# Check OpenSSL against the RFC 5869 Test Case 1 vector, this uses a hex salt and info, 
# so it's a separate check, but it validates the command form:
#
# $ openssl kdf -keylen 42 -binary -kdfopt digest:SHA256 \
#    -kdfopt hexkey:0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b \
#    -kdfopt hexsalt:000102030405060708090a0b0c \
#    -kdfopt hexinfo:f0f1f2f3f4f5f6f7f8f9 HKDF | xxd -p -c 256
#
# The RFC's expected output is:
# 3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865
#
derive_key() {
  local secret_file="$1" context="$2" key
  key="$(openssl kdf -keylen 32 -binary \
          -kdfopt digest:SHA256 \
          -kdfopt hexkey:"$(xxd -p -c 256 "${secret_file}")" \
          -kdfopt salt:"bhsm-demo-hkdf-salt-v1" \
          -kdfopt info:"${context}" \
          HKDF | xxd -p -c 256)"
  if [ "${#key}" -ne 64 ]; then
    echo "HKDF derivation failed (got ${#key} hex chars, expected 64)" >&2
    return 1
  fi
  printf '%s' "${key}"
}

# Dynamically locate the directory where calling sh lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source the config file reliably using the absolute path
source "$SCRIPT_DIR/config.sh"

echo -n "Comparing secrets..."
diff <(xxd -p -c 64 "${SENDER_SECRET_FILE}") <(xxd -p -c 64 "${RECEIVER_SECRET_FILE}") \
  && echo "Secrets MATCH" || { echo "Secrets MISMATCH"; exit 1; }

echo -n "Deriving AES-256 sender key (HKDF-SHA256)..."
CTX="bhsm-demo cms-aes-256-gcm v1"
KEY_S="$(derive_key "${SENDER_SECRET_FILE}" "${CTX}")" && echo "Done!"

echo -n "Deriving AES-256 receiver key (HKDF-SHA256)..."
KEY_R="$(derive_key "${RECEIVER_SECRET_FILE}" "${CTX}")" && echo "Done!"

KEY_ID_HEX="01"   # Arbitrary key identifier, must match on both ends

rm -f "${MSG_AES256_GCM}"   # A sample clear text file
echo -n "hello from the AES-256-GCM CMS demo" > "${MSG_AES256_GCM}"

echo -n "Encrypting (AES-256-GCM, CMS KEK sender)..."
rm -f "${MSG_AES256_GCM_ENC}"

openssl cms -encrypt \
  -in "${MSG_AES256_GCM}" -out "${MSG_AES256_GCM_ENC}" -outform DER \
  -aes-256-gcm \
  -secretkey "${KEY_S}" -secretkeyid "${KEY_ID_HEX}" && echo "Done!"

echo -n "Decrypting (AES-256-GCM, CMS KEK receiver)..."
rm -f "${MSG_AES256_GCM_DEC}"

[ "${#KEY_R}" -eq 64 ] || { echo "Bad key length: ${#KEY_R}" >&2; exit 1; }

openssl cms -decrypt \
  -in "${MSG_AES256_GCM_ENC}" -out "${MSG_AES256_GCM_DEC}" -inform DER \
  -secretkey "${KEY_R}" -secretkeyid "${KEY_ID_HEX}" && echo "Done!"

echo -n "Comparing original and decrypted messages..."
diff "${MSG_AES256_GCM}" "${MSG_AES256_GCM_DEC}" && echo "Round-trip OK, authenticated AES-256-GCM"

echo ""
echo ""
echo "Inspecting the structure (confirms AuthEnvelopedData / GCM was actually used)..."
openssl cms -cmsout -print -inform DER -in "${MSG_AES256_GCM_ENC}" \
  | grep -Ei 'authEnvelopedData|aes-256-gcm|kek' || true

#EOF
