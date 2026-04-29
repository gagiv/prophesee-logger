#!/bin/bash
# generate-cert.sh - Part of ma-agents self-signed-cert skill

TYPE=$1
NAME=${2:-"server"}
DNS=${3:-"localhost"}

if [ "$TYPE" == "root" ]; then
    echo "Generating Root CA..."
    openssl genrsa -out "${NAME}_rootCA.key" 4096
    openssl req -x509 -new -nodes -key "${NAME}_rootCA.key" -sha256 -days 3650 -out "${NAME}_rootCA.crt" \
        -subj "/CN=${NAME}-Root-CA/O=MA-Agents/C=US"
    chmod 600 "${NAME}_rootCA.key"
    echo "Root CA created: ${NAME}_rootCA.crt"

elif [ "$TYPE" == "cert" ]; then
    CA_KEY=$4
    CA_CRT=$5

    if [ -z "$CA_KEY" ] || [ -z "$CA_CRT" ]; then
        echo "Generating standalone self-signed certificate..."
        openssl req -x509 -newnodes -days 365 -newkey rsa:2048 \
            -keyout "${NAME}.key" -out "${NAME}.crt" \
            -subj "/CN=${DNS}/O=MA-Agents" \
            -addext "subjectAltName = DNS:${DNS}"
    else
        echo "Generating certificate signed by CA..."
        openssl genrsa -out "${NAME}.key" 2048
        openssl req -new -key "${NAME}.key" -out "${NAME}.csr" -subj "/CN=${DNS}/O=MA-Agents"
        
        # Extension file for SAN
        echo "subjectAltName = DNS:${DNS}" > "${NAME}.ext"
        
        openssl x509 -req -in "${NAME}.csr" -CA "$CA_CRT" -CAkey "$CA_KEY" -CAcreateserial \
            -out "${NAME}.crt" -days 365 -sha256 -extfile "${NAME}.ext"
        rm "${NAME}.csr" "${NAME}.ext"
    fi
    chmod 600 "${NAME}.key"
    echo "Certificate created: ${NAME}.crt"
else
    echo "Usage: $0 [root|cert] [name] [dns] [ca_key] [ca_crt]"
    exit 1
fi
