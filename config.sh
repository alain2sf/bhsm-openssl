#!/opt/local/bin/bash
# config.sh: sourced by every script

ROOT_DIR="/Users/${USER}"
PROJECT_DIR="${ROOT_DIR}/opt/bhsm-openssl"

OPENSSL_CONF="${PROJECT_DIR}/openssl-pkcs11.cnf"
OPENSSL_MODULES="${ROOT_DIR}/opt/BouncyHsm/build_macos"
PKCS11_MODULE_PATH="${ROOT_DIR}/opt/BouncyHsm/build_macos/BouncyHsm.Pkcs11Lib-arm64.dylib"
BOUNCY_HSM_CFG_STRING="Server=192.168.252.2; Port=8181;"

SLOT_TOKEN="DemoSlotToken1"
KEYPAIR_OBJ="mlkem768-demo"
PIN_FILE="${PROJECT_DIR}/${SLOT_TOKEN}.pin"

MLKEM_PK_PEM="${PROJECT_DIR}/mlkem768_pub.pem"

SENDER_SECRET_FILE="${PROJECT_DIR}/sender_secret.bin"
SENDER_CIPHERTEXT_FILE="${PROJECT_DIR}/ciphertext.bin"
RECEIVER_SECRET_FILE="${PROJECT_DIR}/receiver_secret.bin"

MSG_AES256_CBC="${PROJECT_DIR}/message_aes256_cbc.txt"
MSG_AES256_CBC_IV="${PROJECT_DIR}/message_aes256_cbc.iv"
MSG_AES256_CBC_ENC="${PROJECT_DIR}/message_aes256_cbc.enc"
MSG_AES256_CBC_DEC="${PROJECT_DIR}/message_aes256_cbc_decrypted.txt"

MSG_AES256_GCM="${PROJECT_DIR}/message_aes256_gcm.txt"
MSG_AES256_GCM_ENC="${PROJECT_DIR}/message_aes256_gcm.p7m"
MSG_AES256_GCM_DEC="${PROJECT_DIR}/message_aes256_gcm_decrypted.txt"

# Generate the provider config once and only if not skipped (0-Cleanup.sh)
if [ -z "${SKIP_CONF_CREATE:-}" ] && [ ! -f "${OPENSSL_CONF}" ]; then
  cat > "${OPENSSL_CONF}" <<EOF
[pkcs11_sect]
identity = pkcs11prov
pkcs11_module = "${PKCS11_MODULE_PATH}"
force_login = 1
activate = 1
debug_level = 7
EOF
fi

# Create the slot PIN file once and only if not skipped (0-Cleanup.sh/0-Check-PKCS11.sh)
if [ -z "${SKIP_PIN_CREATE:-}" ] && [ ! -f "${PIN_FILE}" ]; then
    echo -n "Enter HSM Slot PIN: "
    read pin
    echo ${pin} > "${PIN_FILE}"
    chmod 600 "${PIN_FILE}"
fi

#EOF
