#!/bin/bash

# Trouble shooting
# Delete all index files, everything in newcerts dir, and serials
# rm root/index* root/serial* root/newcerts/*
# rm intermediate/index* intermediate/serial* intermediate/newcerts/*
# touch root/index.txt intermediate/index.txt

# Create the root key
openssl genrsa -out root/key.pem
# Create the root certificate
openssl req -config root/openssl.cnf \
  -key root/key.pem \
  -new -x509 -days 14600 -extensions v3_ca \
  -subj "/C=US/ST=California/L=Palo Alto/O=Tommy/OU=IF/CN=root" \
  -out root/cert.pem

# Create the intermediate key
openssl genrsa -out intermediate/key.pem 
# Create the intermediate certificate
openssl req -config intermediate/openssl.cnf -new \
  -key intermediate/key.pem \
  -subj "/C=US/ST=California/L=Palo Alto/O=Tommy/OU=IF/CN=intermediate" \
  -out intermediate/csr.pem
openssl ca -config root/openssl.cnf \
  -extensions v3_intermediate_ca \
  -days 14600 -notext -create_serial -batch \
  -in intermediate/csr.pem \
  -out intermediate/cert.pem

# Create server key
openssl genrsa -out server-key.pem 
# Create CSR
openssl req -config intermediate/openssl.cnf \
  -key server-key.pem \
  -subj "/C=US/ST=California/L=Palo Alto/O=Tommy/OU=IF/CN=localhost" \
  -new -out server-csr.pem
# Create server certificate
openssl ca -config intermediate/openssl.cnf \
  -extensions server_cert -days 14600 -notext -create_serial -batch \
  -in server-csr.pem \
  -out server-cert.pem

# Create the certificate chain file
cat intermediate/cert.pem root/cert.pem > intermediate/ca-cert-chain.pem

# Verify the intermediate file 
openssl verify -CAfile root/cert.pem intermediate/cert.pem

# Verify server certificate has valid chain of trust
openssl verify -CAfile intermediate/ca-cert-chain.pem server-cert.pem
