#!/bin/bash
#
# verify-docker-hardening.sh
# Comprehensive Docker security verification script
# Checks Dockerfile, docker-compose.yml, and running containers
# against CIS, OWASP, and NIST standards
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="${1:-contacts-app}"
CONTAINER_NAME="${2:-contacts-app}"
EXIT_CODE=0

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_check() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    echo -ne "  [$TOTAL_CHECKS] $1... "
}

pass() {
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
    echo -e "${GREEN}✅ PASS${NC}"
}

fail() {
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
    EXIT_CODE=2
    echo -e "${RED}❌ FAIL${NC}"
    [ -n "$1" ] && echo -e "      ${RED}→ $1${NC}"
}

warn() {
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
    echo -e "${YELLOW}⚠️  WARN${NC}"
    [ -n "$1" ] && echo -e "      ${YELLOW}→ $1${NC}"
}

critical() {
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
    EXIT_CODE=1
    echo -e "${RED}🚨 CRITICAL${NC}"
    [ -n "$1" ] && echo -e "      ${RED}→ $1${NC}"
}

# Start verification
echo -e "${BLUE}🔍 Docker Security Verification${NC}"
echo -e "${BLUE}================================${NC}"
echo "Image: $IMAGE_NAME"
echo "Container: $CONTAINER_NAME"

# ============================================================================
# 1. Dockerfile Verification
# ============================================================================
print_header "1. Dockerfile Security"

if [ ! -f "Dockerfile" ]; then
    print_check "Dockerfile exists"
    critical "Dockerfile not found in current directory"
    EXIT_CODE=5
    exit $EXIT_CODE
fi

# Check for specific version tags
print_check "Specific version tags (no :latest)"
if grep -qE "^FROM.*:(latest|alpine)$" Dockerfile; then
    fail "Using :latest or unversioned :alpine tag"
else
    pass
fi

# Check for non-root user
print_check "Non-root user configured"
if grep -qE "^USER (root|[0-9]+)" Dockerfile; then
    if grep -qE "^USER root" Dockerfile; then
        fail "Running as root user"
    else
        pass
    fi
elif grep -qE "^USER [a-zA-Z]" Dockerfile; then
    pass
else
    fail "No USER directive found"
fi

# Check for HEALTHCHECK
print_check "HEALTHCHECK instruction"
if grep -q "^HEALTHCHECK" Dockerfile; then
    pass
else
    warn "Missing HEALTHCHECK instruction"
fi

# Check for hardcoded secrets
print_check "No hardcoded secrets in ENV/ARG"
if grep -iE "^(ENV|ARG).*(SECRET|PASSWORD|KEY|TOKEN|CLIENT_ID)=" Dockerfile | grep -v "REACT_APP_API_BASE_URL" > /dev/null; then
    fail "Potential hardcoded secrets found"
else
    pass
fi

# Check for multi-stage build
print_check "Multi-stage build pattern"
if [ $(grep -c "^FROM" Dockerfile) -ge 2 ]; then
    pass
else
    warn "Not using multi-stage build"
fi

# Check for Alpine base images
print_check "Minimal Alpine base images"
if grep -qE "^FROM.*alpine" Dockerfile; then
    pass
else
    warn "Not using Alpine base images"
fi

# ============================================================================
# 2. docker-compose.yml Verification
# ============================================================================
print_header "2. docker-compose.yml Security"

if [ ! -f "docker-compose.yml" ]; then
    print_check "docker-compose.yml exists"
    warn "docker-compose.yml not found (optional)"
else
    # Check for read-only filesystem
    print_check "Read-only root filesystem"
    if grep -q "read_only: true" docker-compose.yml; then
        pass
    else
        fail "Missing read_only: true"
    fi

    # Check for no-new-privileges
    print_check "No new privileges"
    if grep -q "no-new-privileges:true" docker-compose.yml; then
        pass
    else
        fail "Missing security_opt: no-new-privileges:true"
    fi

    # Check for capability dropping
    print_check "Capabilities dropped"
    if grep -q "cap_drop:" docker-compose.yml; then
        pass
    else
        fail "Missing cap_drop configuration"
    fi

    # Check for tmpfs mounts
    print_check "Tmpfs mounts for writable dirs"
    if grep -q "tmpfs:" docker-compose.yml; then
        pass
    else
        fail "Missing tmpfs mounts"
    fi

    # Check for resource limits
    print_check "Memory limits configured"
    if grep -q "memory:" docker-compose.yml; then
        pass
    else
        warn "Missing memory limits"
    fi

    print_check "CPU limits configured"
    if grep -q "cpus:" docker-compose.yml; then
        pass
    else
        warn "Missing CPU limits"
    fi

    # Check for health check
    print_check "Healthcheck configured"
    if grep -q "healthcheck:" docker-compose.yml; then
        pass
    else
        warn "Missing healthcheck configuration"
    fi

    # Check for privileged mode
    print_check "Not running in privileged mode"
    if grep -q "privileged: true" docker-compose.yml; then
        critical "Running in privileged mode"
    else
        pass
    fi
fi

# ============================================================================
# 3. .dockerignore Verification
# ============================================================================
print_header "3. .dockerignore Configuration"

if [ ! -f ".dockerignore" ]; then
    print_check ".dockerignore exists"
    warn ".dockerignore not found"
else
    print_check ".env excluded from Docker context"
    if grep -qE "^\.env$" .dockerignore; then
        pass
    else
        critical ".env not in .dockerignore - secret leakage risk!"
    fi

    print_check "node_modules excluded"
    if grep -q "node_modules" .dockerignore; then
        pass
    else
        warn "node_modules not excluded"
    fi

    print_check ".git excluded"
    if grep -qE "^\.git" .dockerignore; then
        pass
    else
        warn ".git not excluded"
    fi
fi

# ============================================================================
# 4. Image Security Scanning
# ============================================================================
print_header "4. Image Vulnerability Scanning"

# Check if image exists
if ! docker images --format "{{.Repository}}" | grep -q "^${IMAGE_NAME}$"; then
    print_check "Docker image exists"
    warn "Image '$IMAGE_NAME' not found locally. Skipping image scans."
    echo "      Run 'docker build -t $IMAGE_NAME .' to build the image."
else
    # Check if trivy is installed
    if ! command -v trivy &> /dev/null; then
        print_check "Trivy scanner installed"
        warn "Trivy not installed. Skipping vulnerability scans."
        echo "      Install: brew install aquasecurity/trivy/trivy (macOS)"
        echo "             : apt-get install trivy (Linux)"
    else
        # Scan for CRITICAL vulnerabilities
        print_check "No CRITICAL vulnerabilities"
        if trivy image --quiet --severity CRITICAL --exit-code 1 "$IMAGE_NAME" > /dev/null 2>&1; then
            pass
        else
            critical "CRITICAL vulnerabilities found. Run: trivy image --severity CRITICAL $IMAGE_NAME"
        fi

        # Scan for HIGH vulnerabilities
        print_check "No HIGH vulnerabilities"
        if trivy image --quiet --severity HIGH --exit-code 1 "$IMAGE_NAME" > /dev/null 2>&1; then
            pass
        else
            fail "HIGH vulnerabilities found. Run: trivy image --severity HIGH $IMAGE_NAME"
        fi

        # Scan for leaked secrets
        print_check "No leaked secrets in image"
        if trivy image --quiet --scanners secret --exit-code 1 "$IMAGE_NAME" > /dev/null 2>&1; then
            pass
        else
            critical "Secrets detected in image! Run: trivy image --scanners secret $IMAGE_NAME"
        fi
    fi

    # Check image size
    print_check "Optimized image size (< 100MB)"
    IMAGE_SIZE=$(docker images --format "{{.Size}}" "$IMAGE_NAME" | head -1 | sed 's/MB//' | sed 's/GB/*1024/' | bc 2>/dev/null || echo "0")
    if [ -n "$IMAGE_SIZE" ] && [ "$IMAGE_SIZE" != "0" ]; then
        if (( $(echo "$IMAGE_SIZE < 100" | bc -l) )); then
            pass
        else
            warn "Image size is ${IMAGE_SIZE}MB (recommended < 100MB)"
        fi
    else
        warn "Could not determine image size"
    fi

    # Check for .env in image
    print_check ".env file not baked into image"
    if docker run --rm "$IMAGE_NAME" sh -c "ls -la / 2>/dev/null | grep -q .env"; then
        critical ".env file found in image! Secrets leaked!"
    else
        pass
    fi
fi

# ============================================================================
# 5. Runtime Security (if container is running)
# ============================================================================
print_header "5. Runtime Security Verification"

if ! docker ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    echo -e "${YELLOW}  Container '$CONTAINER_NAME' is not running.${NC}"
    echo -e "${YELLOW}  Run 'docker-compose up -d' to enable runtime checks.${NC}"
else
    # Check container runs as non-root
    print_check "Container runs as non-root"
    CONTAINER_USER=$(docker exec "$CONTAINER_NAME" whoami 2>/dev/null || echo "root")
    if [ "$CONTAINER_USER" != "root" ]; then
        pass
    else
        critical "Container running as root user!"
    fi

    # Check user ID is not 0
    print_check "User ID is not 0 (root)"
    USER_ID=$(docker exec "$CONTAINER_NAME" id -u 2>/dev/null || echo "0")
    if [ "$USER_ID" != "0" ]; then
        pass
    else
        critical "Container running with UID 0 (root)!"
    fi

    # Check read-only filesystem
    print_check "Root filesystem is read-only"
    if docker exec "$CONTAINER_NAME" sh -c "touch /test 2>/dev/null"; then
        fail "Root filesystem is writable"
        docker exec "$CONTAINER_NAME" sh -c "rm /test 2>/dev/null" || true
    else
        pass
    fi

    # Check tmpfs is writable
    print_check "Tmpfs mount is writable"
    if docker exec "$CONTAINER_NAME" sh -c "touch /tmp/test 2>/dev/null && rm /tmp/test 2>/dev/null"; then
        pass
    else
        warn "Tmpfs mount /tmp is not writable"
    fi

    # Check health status
    print_check "Container is healthy"
    HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "none")
    if [ "$HEALTH_STATUS" = "healthy" ]; then
        pass
    elif [ "$HEALTH_STATUS" = "none" ]; then
        warn "No health check configured"
    else
        fail "Container health status: $HEALTH_STATUS"
    fi

    # Check capabilities
    print_check "Capabilities dropped"
    CAPS_DROPPED=$(docker inspect --format='{{.HostConfig.CapDrop}}' "$CONTAINER_NAME" 2>/dev/null || echo "[]")
    if echo "$CAPS_DROPPED" | grep -q "ALL"; then
        pass
    else
        warn "Not all capabilities dropped"
    fi

    # Check memory limit
    print_check "Memory limit enforced"
    MEMORY_LIMIT=$(docker inspect --format='{{.HostConfig.Memory}}' "$CONTAINER_NAME" 2>/dev/null || echo "0")
    if [ "$MEMORY_LIMIT" != "0" ]; then
        pass
    else
        warn "No memory limit set"
    fi
fi

# ============================================================================
# 6. Git Secret Protection
# ============================================================================
print_header "6. Git Secret Protection"

if [ -d ".git" ]; then
    # Check .env in .gitignore
    print_check ".env in .gitignore"
    if [ -f ".gitignore" ] && grep -qE "^\.env$" .gitignore; then
        pass
    else
        critical ".env not in .gitignore! Secrets may be committed!"
    fi

    # Check .env.example exists
    print_check ".env.example exists (template)"
    if [ -f ".env.example" ]; then
        pass
    else
        warn ".env.example not found"
    fi

    # Check if .env is committed
    print_check ".env not committed to git"
    if git ls-files --error-unmatch .env > /dev/null 2>&1; then
        critical ".env is tracked by git! Remove immediately!"
    else
        pass
    fi
else
    echo -e "${YELLOW}  Not a git repository. Skipping git checks.${NC}"
fi

# ============================================================================
# Summary
# ============================================================================
print_header "Verification Summary"

echo ""
echo "  Total checks:    $TOTAL_CHECKS"
echo -e "  ${GREEN}Passed:          $PASSED_CHECKS${NC}"
echo -e "  ${YELLOW}Warnings:        $WARNING_CHECKS${NC}"
echo -e "  ${RED}Failed:          $FAILED_CHECKS${NC}"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✅ All critical security checks passed!${NC}"
    if [ $WARNING_CHECKS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNING_CHECKS warning(s) - consider addressing these.${NC}"
    fi
else
    echo -e "${RED}❌ $FAILED_CHECKS security check(s) failed!${NC}"
    echo -e "${RED}   Please fix the issues above before deploying.${NC}"
fi

echo ""

exit $EXIT_CODE
