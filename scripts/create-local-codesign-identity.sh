#!/usr/bin/env zsh
set -euo pipefail

IDENTITY_NAME="${SYNONYM_PICKER_CODESIGN_IDENTITY:-SynonymPicker Local Code Signing}"
KEYCHAIN="$(security default-keychain -d user | tr -d '"')"
CERT_DIR=".build/local-codesign"
CERT_PEM="${CERT_DIR}/certificate.pem"
KEY_PEM="${CERT_DIR}/private-key.pem"
P12_FILE="${CERT_DIR}/identity.p12"
OPENSSL_CONFIG="${CERT_DIR}/openssl.cnf"

if security find-identity -v -p codesigning "${KEYCHAIN}" | grep -F "\"${IDENTITY_NAME}\"" >/dev/null; then
  echo "Code signing identity already exists: ${IDENTITY_NAME}"
  exit 0
fi

mkdir -p "${CERT_DIR}"

cat > "${OPENSSL_CONFIG}" <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = codesign_ext

[ dn ]
CN = ${IDENTITY_NAME}

[ codesign_ext ]
basicConstraints = critical,CA:true
keyUsage = critical,digitalSignature,keyCertSign
extendedKeyUsage = codeSigning
subjectKeyIdentifier = hash
EOF

openssl req \
  -new \
  -newkey rsa:2048 \
  -nodes \
  -x509 \
  -days 3650 \
  -keyout "${KEY_PEM}" \
  -out "${CERT_PEM}" \
  -config "${OPENSSL_CONFIG}" \
  -extensions codesign_ext

openssl pkcs12 \
  -export \
  -inkey "${KEY_PEM}" \
  -in "${CERT_PEM}" \
  -out "${P12_FILE}" \
  -passout pass:

security import "${P12_FILE}" \
  -k "${KEYCHAIN}" \
  -P "" \
  -A \
  -T /usr/bin/codesign

security add-trusted-cert \
  -r trustRoot \
  -p codeSign \
  -k "${KEYCHAIN}" \
  "${CERT_PEM}"

if ! security find-identity -v -p codesigning "${KEYCHAIN}" | grep -F "\"${IDENTITY_NAME}\"" >/dev/null; then
  echo "Failed to create a valid code signing identity in ${KEYCHAIN}" >&2
  echo "Open Keychain Access and check whether '${IDENTITY_NAME}' has both a certificate and private key." >&2
  exit 1
fi

echo "Created code signing identity: ${IDENTITY_NAME}"
echo "If codesign asks for keychain access later, allow access for /usr/bin/codesign."
