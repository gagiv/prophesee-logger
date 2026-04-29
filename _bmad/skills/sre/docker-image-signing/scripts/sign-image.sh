#!/bin/bash
# sign-image.sh - Part of ma-agents docker-image-signing skill

IMAGE=$1
CERT=$2
KEY=$3
PASSPHRASE=$4

if [ -z "$IMAGE" ] || [ -z "$CERT" ] || [ -z "$KEY" ]; then
    echo "Usage: $0 <image_digest> <cert_file> <key_file> [passphrase]"
    exit 1
fi

echo "Signing image: $IMAGE"

# Check for cosign
if command -v cosign &> /dev/null; then
    echo "Using Cosign for signing..."
    if [ -n "$PASSPHRASE" ]; then
        export COSIGN_PASSWORD=$PASSPHRASE
    fi
    cosign sign --key "$KEY" --cert "$CERT" "$IMAGE"
else
    echo "Error: cosign not found. Please install cosign to use this skill."
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "Successfully signed $IMAGE"
else
    echo "Failed to sign $IMAGE"
    exit 1
fi
