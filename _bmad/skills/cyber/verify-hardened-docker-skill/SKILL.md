---
name: Verify Hardened Docker
description: Comprehensive security verification for Docker configurations against CIS, OWASP, and NIST standards
---
# Verify Hardened Docker

## Overview

This skill performs comprehensive security verification of Docker configurations to ensure compliance with industry standards:
- **CIS Docker Benchmark v1.6.0**
- **OWASP Docker Security Cheat Sheet**
- **NIST Application Container Security Guide (SP 800-190)**

## Bundled Tools

### Scripts (scripts/)
| Script | Purpose |
|--------|---------|
| `verify-docker-hardening.sh` | Complete security verification suite |
| `scan-vulnerabilities.sh` | Trivy vulnerability scanning |
| `scan-secrets.sh` | Secret leakage detection |
| `check-runtime-security.sh` | Runtime security validation |

---

## What Gets Verified

### Image Security
- [ ] Specific version tags (not :latest or unversioned)
- [ ] Minimal base images (Alpine preferred)
- [ ] Non-root user execution (USER directive)
- [ ] Read-only file permissions for static content
- [ ] No leaked secrets in image layers
- [ ] No hardcoded credentials
- [ ] Build cache cleanup
- [ ] Unnecessary packages removed
- [ ] HEALTHCHECK instruction present

### Dockerfile Hardening
- [ ] Multi-stage build pattern
- [ ] Non-root user creation and usage
- [ ] Correct file ownership (chown)
- [ ] Read-only permissions (chmod 444 for static files)
- [ ] No sensitive data in ENV or ARG
- [ ] Proper WORKDIR usage
- [ ] Minimal layer count
- [ ] Build-time secret handling (BuildKit mounts)

### docker-compose.yml Security
- [ ] Read-only root filesystem (read_only: true)
- [ ] Tmpfs mounts for writable directories
- [ ] Capability dropping (cap_drop: ALL)
- [ ] Minimal capability additions
- [ ] No-new-privileges enabled
- [ ] Resource limits (memory, CPU)
- [ ] Custom network isolation
- [ ] Health check configuration
- [ ] Restart policy set
- [ ] No privileged mode

### Runtime Security
- [ ] Container runs as non-root user
- [ ] Root filesystem is read-only
- [ ] Tmpfs mounts are writable
- [ ] No privilege escalation possible
- [ ] Resource limits enforced
- [ ] Health checks passing
- [ ] No unnecessary capabilities
- [ ] Security options active

### Network Security (nginx)
- [ ] Nginx version hidden (server_tokens off)
- [ ] TLS 1.2+ only
- [ ] Strong cipher suites
- [ ] HSTS header present
- [ ] CSP headers configured
- [ ] Security headers (X-Frame-Options, X-Content-Type-Options)
- [ ] Non-privileged ports (8080/8443) OR CAP_NET_BIND_SERVICE

### Secrets Management
- [ ] .env in .gitignore
- [ ] .env.example committed (template only)
- [ ] No hardcoded secrets in Dockerfile
- [ ] No secrets in environment variables
- [ ] BuildKit secret mounts used (if applicable)
- [ ] Secrets mounted read-only
- [ ] No secrets in image history
- [ ] Secret scanning passed

### Vulnerability Scanning
- [ ] No CRITICAL vulnerabilities
- [ ] No HIGH vulnerabilities
- [ ] No leaked secrets detected
- [ ] Base image is up-to-date
- [ ] All dependencies scanned

---

## Usage

### Quick Verification

Run the complete verification suite:

```bash
./scripts/verify-docker-hardening.sh [image-name]
```

**Example:**
```bash
./scripts/verify-docker-hardening.sh contacts-app
```

### Step-by-Step Verification

#### 1. Verify Dockerfile

```bash
# Check for basic security issues
grep -E "^FROM.*:latest|^USER root|^ENV.*SECRET|^ARG.*PASSWORD" Dockerfile && echo "⚠️ Security issues found" || echo "✅ Basic checks passed"

# Verify specific version tags
grep -E "^FROM.*:[0-9]+\.[0-9]+\.[0-9]+" Dockerfile && echo "✅ Specific version tags" || echo "❌ Missing specific versions"

# Verify non-root user
grep -E "^USER [^r]" Dockerfile && echo "✅ Non-root user set" || echo "❌ Running as root"

# Verify HEALTHCHECK
grep "^HEALTHCHECK" Dockerfile && echo "✅ Health check present" || echo "❌ Missing HEALTHCHECK"
```

#### 2. Scan for Vulnerabilities

```bash
# Install trivy if not already installed
# macOS: brew install aquasecurity/trivy/trivy
# Linux: apt-get install trivy
# Windows: choco install trivy

# Scan image for vulnerabilities
trivy image --severity HIGH,CRITICAL [image-name]

# Fail on HIGH or CRITICAL
trivy image --severity HIGH,CRITICAL --exit-code 1 [image-name]
```

#### 3. Scan for Leaked Secrets

```bash
# Scan for secrets in image
trivy image --scanners secret [image-name]

# Check image history for secrets
docker history [image-name] --no-trunc | grep -iE "secret|password|key|token|api_key"

# Verify .env not in image
docker run --rm [image-name] ls -la / | grep .env || echo "✅ .env not found in image"

# Verify no hardcoded secrets
docker run --rm [image-name] env | grep -iE "client_id|client_secret|api_key" || echo "✅ No hardcoded secrets"
```

#### 4. Verify docker-compose.yml

```bash
# Check for security options
grep "read_only: true" docker-compose.yml && echo "✅ Read-only filesystem"
grep "no-new-privileges:true" docker-compose.yml && echo "✅ No new privileges"
grep "cap_drop:" docker-compose.yml && echo "✅ Capabilities dropped"
grep -A 5 "resources:" docker-compose.yml | grep "memory:" && echo "✅ Memory limits set"
grep -A 5 "resources:" docker-compose.yml | grep "cpus:" && echo "✅ CPU limits set"
grep "tmpfs:" docker-compose.yml && echo "✅ Tmpfs mounts configured"
```

#### 5. Runtime Security Verification

Build and run the container first:
```bash
docker-compose up -d
```

Then verify:

```bash
# Verify container runs as non-root
docker exec [container-name] whoami
# Expected output: nginx (or other non-root user)

# Verify read-only filesystem
docker exec [container-name] touch /test
# Expected: Permission denied (read-only filesystem)

# Verify tmpfs is writable
docker exec [container-name] touch /tmp/test
# Expected: Success

# Verify user ID is not 0 (root)
docker exec [container-name] id
# Expected: uid=101(nginx) or similar (not uid=0)

# Verify capabilities
docker inspect [container-name] | jq '.[0].HostConfig.CapDrop'
# Expected: ["ALL"] or similar

# Verify resource limits
docker stats [container-name] --no-stream
# Expected: Memory usage < configured limit

# Verify health status
docker ps --filter "name=[container-name]" --format "{{.Status}}"
# Expected: "Up ... (healthy)"
```

#### 6. Network Security (nginx)

```bash
# Verify nginx version is hidden
curl -I http://localhost | grep Server
# Expected: Server: nginx (no version number)

# Verify security headers present
curl -I https://localhost | grep -E "Content-Security-Policy|X-Frame-Options|X-Content-Type-Options|Strict-Transport-Security"

# Verify gzip compression
curl -H "Accept-Encoding: gzip" -I http://localhost | grep "Content-Encoding: gzip"
```

#### 7. Verify .dockerignore

```bash
# Check .dockerignore exists
test -f .dockerignore && echo "✅ .dockerignore exists" || echo "❌ Missing .dockerignore"

# Verify critical exclusions
grep -E "^\.env$|^node_modules/|^\.git/" .dockerignore && echo "✅ Critical exclusions present"
```

---

## Automated Verification Script

The `verify-docker-hardening.sh` script performs all checks automatically:

```bash
#!/bin/bash
set -e

IMAGE_NAME="${1:-contacts-app}"
CONTAINER_NAME="${2:-contacts-app}"

echo "🔍 Docker Security Verification for: $IMAGE_NAME"
echo "================================================"

# 1. Dockerfile checks
echo "📄 Verifying Dockerfile..."
./scripts/verify-dockerfile.sh

# 2. Vulnerability scanning
echo "🛡️ Scanning for vulnerabilities..."
./scripts/scan-vulnerabilities.sh "$IMAGE_NAME"

# 3. Secret scanning
echo "🔐 Scanning for leaked secrets..."
./scripts/scan-secrets.sh "$IMAGE_NAME"

# 4. docker-compose.yml checks
echo "🐳 Verifying docker-compose.yml..."
./scripts/verify-compose.sh

# 5. Runtime security (if container is running)
if docker ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    echo "🚀 Verifying runtime security..."
    ./scripts/check-runtime-security.sh "$CONTAINER_NAME"
else
    echo "⚠️ Container not running, skipping runtime checks"
    echo "   Run 'docker-compose up -d' to enable runtime verification"
fi

echo ""
echo "✅ Security verification complete!"
```

---

## CIS Docker Benchmark Compliance

### Critical CIS Controls

| CIS ID | Control | Verification |
|--------|---------|--------------|
| 4.1 | Create user for container | `grep "^USER" Dockerfile` |
| 4.3 | Verify file permissions | `docker exec ... find /usr/share/nginx/html -type f -perm /022` |
| 4.5 | Enable Content trust | `grep -E "FROM.*:[0-9]" Dockerfile` |
| 5.7 | Don't map privileged ports | Check ports are > 1024 or CAP_NET_BIND_SERVICE |
| 5.10 | Set memory limit | `grep "memory:" docker-compose.yml` |
| 5.11 | Set CPU priority | `grep "cpus:" docker-compose.yml` |
| 5.12 | Read-only root filesystem | `grep "read_only: true" docker-compose.yml` |
| 5.25 | No new privileges | `grep "no-new-privileges:true" docker-compose.yml` |

### Verification Command

```bash
# Run all CIS checks
grep "^USER [^r]" Dockerfile && echo "✅ CIS 4.1"
docker exec [container] find /usr/share/nginx/html -type f -perm /022 && echo "❌ CIS 4.3" || echo "✅ CIS 4.3"
grep -E "FROM.*:[0-9]" Dockerfile && echo "✅ CIS 4.5"
grep "read_only: true" docker-compose.yml && echo "✅ CIS 5.12"
grep "no-new-privileges:true" docker-compose.yml && echo "✅ CIS 5.25"
```

---

## OWASP Compliance

| OWASP Control | Verification |
|---------------|--------------|
| Run as non-root | `docker exec ... whoami` → nginx |
| Minimal base image | `FROM *-alpine` in Dockerfile |
| Scan vulnerabilities | `trivy image ...` |
| Limit resources | `docker stats` |
| Read-only filesystem | `docker exec ... touch /test` → fails |
| Drop capabilities | `docker inspect ... \| jq '.[0].HostConfig.CapDrop'` |
| Security options | `grep security_opt docker-compose.yml` |
| Specific tags | No `:latest` in Dockerfile |

---

## Common Security Issues

### Critical Issues (Fix Immediately)

1. **Running as root**
   - Detection: `docker exec [container] whoami` → root
   - Fix: Add `USER nginx` to Dockerfile

2. **Hardcoded secrets**
   - Detection: `trivy image --scanners secret`
   - Fix: Use BuildKit secrets or Docker Secrets

3. **CRITICAL/HIGH vulnerabilities**
   - Detection: `trivy image --severity CRITICAL,HIGH`
   - Fix: Update base images and dependencies

4. **Writable root filesystem**
   - Detection: `docker exec [container] touch /test` → succeeds
   - Fix: Add `read_only: true` to docker-compose.yml

5. **No resource limits**
   - Detection: No `memory:` or `cpus:` in docker-compose.yml
   - Fix: Add resource limits under `deploy.resources`

### Warning Issues (Should Fix)

1. **Using :latest tag**
   - Detection: `grep ":latest" Dockerfile`
   - Fix: Use specific version tags

2. **Nginx version exposed**
   - Detection: `curl -I http://localhost | grep "Server: nginx/"`
   - Fix: Add `server_tokens off;` to nginx.conf

3. **Missing security headers**
   - Detection: `curl -I https://localhost | grep CSP` → not found
   - Fix: Add security headers to nginx.conf

4. **No health check**
   - Detection: `docker ps` → no (healthy) status
   - Fix: Add HEALTHCHECK to Dockerfile

5. **Large image size**
   - Detection: `docker images | grep [image-name]` → > 100MB
   - Fix: Use multi-stage builds, clean build cache

---

## Troubleshooting

### "No such image" error

```bash
# Build the image first
docker build -t [image-name] .
```

### "Container not running" warning

```bash
# Start the container
docker-compose up -d

# Wait for health check
sleep 10

# Re-run verification
./scripts/verify-docker-hardening.sh
```

### Trivy not installed

```bash
# macOS
brew install aquasecurity/trivy/trivy

# Linux (Debian/Ubuntu)
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# Windows
choco install trivy
```

### Permission denied errors

```bash
# Make scripts executable
chmod +x scripts/*.sh
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All security checks passed |
| 1 | CRITICAL vulnerabilities found |
| 2 | Hardening checks failed |
| 3 | Secret leakage detected |
| 4 | Runtime security violations |
| 5 | Missing required files |

---

## References

- [CIS Docker Benchmark v1.6.0](https://www.cisecurity.org/benchmark/docker)
- [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [NIST SP 800-190](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
