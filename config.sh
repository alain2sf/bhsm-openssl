#!/opt/local/bin/bash

ROOT_DIR=/Users/${USER}
PROJECT_DIR=${ROOT_DIR}/opt/bhsm-openssl

OPENSSL_CONF=${PROJECT_DIR}/openssl-pkcs11.cnf
OPENSSL_MODULES=${ROOT_DIR}/opt/BouncyHsm/build_macos
PKCS11_MODULE_PATH=${ROOT_DIR}/opt/BouncyHsm/build_macos/BouncyHsm.Pkcs11Lib-arm64.dylib

BOUNCY_HSM_CFG_STRING="Server=192.168.252.2; Port=8181;"

SLOT_TOKEN=DemoSlotToken1
KEYPAIR_OBJ=mlkem768-demo

PIN_FILE=${PROJECT_DIR}/${SLOT_TOKEN}.pin

MLKEM_PK_PEM=${PROJECT_DIR}/mlkem768_pub.pem

SENDER_SECRET_FILE=${PROJECT_DIR}/sender_secret.bin
SENDER_CIPHERTEXT_FILE=${PROJECT_DIR}/ciphertext.bin

RECEIVER_SECRET_FILE=${PROJECT_DIR}/receiver_secret.bin

MSG_AES256_CBC=${PROJECT_DIR}/message_aes256_cbc.txt
MSG_AES256_CBC_IV=${PROJECT_DIR}/message_aes256_cbc.iv
MSG_AES256_CBC_ENC=${PROJECT_DIR}/message_aes256_cbc.enc
MSG_AES256_CBC_DEC=${PROJECT_DIR}/message_aes256_cbc_decrypted.txt

MSG_AES256_GCM=${PROJECT_DIR}/message_aes256_gcm.txt
MSG_AES256_GCM_ENC=${PROJECT_DIR}/message_aes256_gcm.p7m
MSG_AES256_GCM_DEC=${PROJECT_DIR}/message_aes256_gcm_decrypted.txt

OPENSSL_CONFIG=openssl-pkcs11.cnf

if [ ! -f "${OPENSSL_CONFIG}" ]; then
   echo "[pkcs11_sect]" >> ${OPENSSL_CONFIG}
   echo "identity = pkcs11prov" >> ${OPENSSL_CONFIG}
   echo "pkcs11_module = ${ROOT_DIR}/opt/BouncyHsm/build_macos/BouncyHsm.Pkcs11Lib-arm64.dylib" >> ${OPENSSL_CONFIG}
   echo "force_login = 1" >> ${OPENSSL_CONFIG}
   echo "activate = 1" >> ${OPENSSL_CONFIG}
   echo "debug_level = 7" >> ${OPENSSL_CONFIG}
fi

#EOF
