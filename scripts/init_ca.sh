#!/bin/bash
if [ ! -d "/etc/apache2/ca-tools/data/certs" ]; then
  ls
  cd ca-tools && npm run init && CERT_DOMAIN=${CA_SUBJECT_ALT_NAME} npm run new-cert
  cp /etc/apache2/ca-tools/data/certs/${CA_SUBJECT_ALT_NAME}.cert.pem /etc/apache2/certs/base.cert.pem
  cp /etc/apache2/ca-tools/data/private/${CA_SUBJECT_ALT_NAME}.key.pem /etc/apache2/certs/base.key.pem
fi