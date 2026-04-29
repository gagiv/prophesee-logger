#!/bin/bash

# JS/TS Security Verification Script (OWASP Top 10 2025)
# This script performs a series of security checks on a JavaScript/TypeScript project.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}   JS/TS Security Audit - OWASP Top 10 2025         ${NC}"
echo -e "${CYAN}====================================================${NC}\n"

# A03:2025 - Software Supply Chain Failures
echo -e "${YELLOW}[1/5] A03:2025 - Software Supply Chain Failures${NC}"
SUPPLY_CHAIN_ISSUES=0
if [ ! -f "package-lock.json" ] && [ ! -f "yarn.lock" ] && [ ! -f "pnpm-lock.yaml" ]; then
    echo -e "${RED}✗ CRITICAL: No lockfile found (package-lock.json, yarn.lock, or pnpm-lock.yaml).${NC}"
    echo "  Impact: Non-deterministic builds increase supply chain vulnerability."
    SUPPLY_CHAIN_ISSUES=$((SUPPLY_CHAIN_ISSUES + 1))
fi

HTTP_REGISTRY=$(grep -r "http://" package.json 2>/dev/null)
if [ ! -z "$HTTP_REGISTRY" ]; then
    echo -e "${RED}✗ WARNING: Insecure registry found in package.json (using HTTP instead of HTTPS).${NC}"
    echo "$HTTP_REGISTRY"
    SUPPLY_CHAIN_ISSUES=$((SUPPLY_CHAIN_ISSUES + 1))
fi

if [ $SUPPLY_CHAIN_ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓ No immediate supply chain issues found.${NC}\n"
else
    echo -e "${RED}✗ Total supply chain issues: $SUPPLY_CHAIN_ISSUES${NC}\n"
fi

# A03:2025 / A06:2021 - Dependency Audit
echo -e "${YELLOW}[2/5] A03:2025 - Vulnerable Components (Audit)${NC}"
if [ -f "package-lock.json" ]; then
    npm audit --audit-level=high
    AUDIT_EXIT=$?
elif [ -f "yarn.lock" ]; then
    yarn audit --level high
    AUDIT_EXIT=$?
else
    echo -e "${YELLOW}  Skipping dependency audit: No lockfile found.${NC}"
    AUDIT_EXIT=0
fi

if [ $AUDIT_EXIT -eq 0 ]; then
    echo -e "${GREEN}✓ No high-severity vulnerabilities in dependencies.${NC}\n"
else
    echo -e "${RED}✗ Vulnerabilities found. Run 'npm audit fix'.${NC}\n"
fi

# A01/A04/A05/A08 - Static Analysis (SAST)
echo -e "${YELLOW}[3/5] Static Analysis (OWASP A01, A04, A05, A08)${NC}"
declare -A DANGEROUS_PATTERNS
DANGEROUS_PATTERNS["A01: SSRF/Access Control"]="fetch\(\`|axios\.get\(\`|http\.get\(\`"
DANGEROUS_PATTERNS["A05: Injection"]="eval\(|new Function\(|child_process\.exec\(|require\('child_process'\)\.exec"
DANGEROUS_PATTERNS["A04: Cryptographic Failures"]="crypto\.createHash\('md5'\)|crypto\.createHash\('sha1'\)|Math\.random\(\)"
DANGEROUS_PATTERNS["A08: Software/Data Integrity"]="unserialize\(|JSON\.parse\("
DANGEROUS_PATTERNS["A07: Authentication Failures"]="res\.cookie\(.*httpOnly: false|res\.cookie\(.*secure: false"

FOUND_ISSUES=0
for cat in "A01: SSRF/Access Control" "A05: Injection" "A04: Cryptographic Failures" "A08: Software/Data Integrity" "A07: Authentication Failures"; do
    pattern=${DANGEROUS_PATTERNS[$cat]}
    MATCHES=$(grep -rnE "$pattern" --include="*.js" --include="*.ts" --exclude-dir=node_modules . 2>/dev/null)
    if [ ! -z "$MATCHES" ]; then
        echo -e "${RED}✗ Found Risk: [$cat]${NC}"
        echo "$MATCHES" | sed 's/^/  /'
        FOUND_ISSUES=$((FOUND_ISSUES + 1))
    fi
done

if [ $FOUND_ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓ No dangerous patterns detected via SAST.${NC}\n"
else
    echo -e "${RED}✗ Total dangerous patterns: $FOUND_ISSUES${NC}\n"
fi

# A10:2025 - Mishandling of Exceptional Conditions
echo -e "${YELLOW}[4/5] A10:2025 - Mishandling of Exceptional Conditions${NC}"
EMPTY_CATCH=$(grep -rnE "catch\s*\(\w*\)\s*\{\s*\}" --include="*.js" --include="*.ts" --exclude-dir=node_modules . 2>/dev/null)
FOUND_EXCEPTION_ISSUES=0
if [ ! -z "$EMPTY_CATCH" ]; then
    echo -e "${RED}✗ Found Risk: Empty catch blocks (Swallowing exceptions)${NC}"
    echo "$EMPTY_CATCH" | sed 's/^/  /'
    FOUND_EXCEPTION_ISSUES=$((FOUND_EXCEPTION_ISSUES + 1))
fi

if [ $FOUND_EXCEPTION_ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓ Exception handling patterns appear secure.${NC}\n"
else
    echo -e "${RED}✗ Total exception handling issues: $FOUND_EXCEPTION_ISSUES${NC}\n"
fi

# Secret Detection (A01/A07)
echo -e "${YELLOW}[5/5] A01/A07 - Hardcoded Secrets Scanning${NC}"
SECRET_PATTERNS=("AIza[0-9A-Za-z-_]{35}" "sk_live_[0-9a-zA-Z]{24}" "xox[pb]-[0-9]{12}-[0-9]{12}-[0-9]{12}-[a-z0-9]{32}" "-----BEGIN RSA PRIVATE KEY-----")

FOUND_SECRETS=0
for pattern in "${SECRET_PATTERNS[@]}"; do
    MATCHES=$(grep -rnE "$pattern" --include="*.js" --include="*.ts" --include="*.env" --exclude-dir=node_modules . 2>/dev/null)
    if [ ! -z "$MATCHES" ]; then
        echo -e "${RED}✗ Found Risk: Potential secret leakage ($pattern)${NC}"
        echo "$MATCHES" | sed 's/^/  /'
        FOUND_SECRETS=$((FOUND_SECRETS + 1))
    fi
done

if [ $FOUND_SECRETS -eq 0 ]; then
    echo -e "${GREEN}✓ No hardcoded secrets detected.${NC}\n"
else
    echo -e "${RED}✗ Total secrets found: $FOUND_SECRETS${NC}\n"
fi

# Summary
echo -e "${CYAN}----------------------------------------------------${NC}"
echo -e "${CYAN}   OWASP 2025 Audit Summary                         ${NC}"
echo -e "${CYAN}----------------------------------------------------${NC}"
[ $SUPPLY_CHAIN_ISSUES -eq 0 ] && echo -e "A03: Supply Chain        - ${GREEN}PASS${NC}" || echo -e "A03: Supply Chain        - ${RED}FAIL${NC}"
[ $AUDIT_EXIT -eq 0 ]           && echo -e "A03: Vulnerabilities     - ${GREEN}PASS${NC}" || echo -e "A03: Vulnerabilities     - ${RED}FAIL${NC}"
[ $FOUND_ISSUES -eq 0 ]        && echo -e "A01/04/05/08: Code Patterns - ${GREEN}PASS${NC}" || echo -e "A01/04/05/08: Code Patterns - ${RED}FAIL${NC}"
[ $FOUND_EXCEPTION_ISSUES -eq 0 ] && echo -e "A10: Exception Handling  - ${GREEN}PASS${NC}" || echo -e "A10: Exception Handling  - ${RED}FAIL${NC}"
[ $FOUND_SECRETS -eq 0 ]       && echo -e "A01/A07: Secrets         - ${GREEN}PASS${NC}" || echo -e "A01/A07: Secrets         - ${RED}FAIL${NC}"
echo -e "${CYAN}----------------------------------------------------${NC}"

if [ $AUDIT_EXIT -eq 0 ] && [ $FOUND_ISSUES -eq 0 ] && [ $FOUND_SECRETS -eq 0 ] && [ $SUPPLY_CHAIN_ISSUES -eq 0 ] && [ $FOUND_EXCEPTION_ISSUES -eq 0 ]; then
    echo -e "${GREEN}Final Result: SECURE${NC}"
    exit 0
else
    echo -e "${RED}Final Result: VULNERABLE${NC}"
    exit 1
fi
