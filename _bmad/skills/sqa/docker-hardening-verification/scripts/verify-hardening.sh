#!/bin/bash
# verify-hardening.sh - Part of ma-agents docker-hardening-verification skill

IMAGE=$1

if [ -z "$IMAGE" ]; then
    echo "Usage: $0 <image_name>"
    exit 1
fi

echo "Auditing image: $IMAGE"

# 1. Check User
USER_VAL=$(docker inspect --format='{{.Config.User}}' "$IMAGE")

if [ -z "$USER_VAL" ] || [ "$USER_VAL" == "root" ] || [ "$USER_VAL" == "0" ]; then
    echo "[FAIL] Image runs as root! Definining a non-root USER is mandatory for hardened clusters."
else
    echo "[PASS] Image runs as user: $USER_VAL"
fi

# 2. Check for sensitive capabilities (simplified check)
CAPS=$(docker inspect --format='{{.Config.CapAdd}}' "$IMAGE")
if [ "$CAPS" != "<nil>" ] && [ -n "$CAPS" ]; then
    echo "[WARNING] Image has explicitly added capabilities: $CAPS"
fi

# 3. Check for exposed ports
PORTS=$(docker inspect --format='{{range $p, $conf := .Config.ExposedPorts}}{{$p}} {{end}}' "$IMAGE")
echo "[INFO] Exposed ports: ${PORTS:-none}"

# 4. OpenShift specific check (arbitrary UID support)
# This is a heuristic check looking for common entrypoint patterns
ENTRYPOINT=$(docker inspect --format='{{.Config.Entrypoint}}' "$IMAGE")
if [[ "$ENTRYPOINT" == *"bash"* ]]; then
    echo "[INFO] Entrypoint uses bash, manual check for UID mapping recommended."
fi

echo "Summary: Audit complete for $IMAGE"
