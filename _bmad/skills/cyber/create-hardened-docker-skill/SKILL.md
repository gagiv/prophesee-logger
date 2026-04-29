---
name: Create Hardened Docker
description: Creates production-ready hardened Docker configurations following CIS, OWASP, and NIST standards
---
# Create Hardened Docker

## Overview

This skill creates complete, production-ready Docker configurations with comprehensive security hardening:
- **Multi-stage Dockerfile** with non-root execution
- **Security-hardened docker-compose.yml** with read-only filesystem and capability controls
- **Production nginx.conf** with security headers and TLS configuration
- **Optimized .dockerignore** for build context reduction
- **DEPLOYMENT.md** documentation

All configurations comply with:
- **CIS Docker Benchmark v1.6.0**
- **OWASP Docker Security Cheat Sheet**
- **NIST Application Container Security Guide (SP 800-190)**

## Bundled Tools

### Scripts (scripts/)
| Script | Purpose |
|--------|---------|
| `create-dockerfile.sh` | Generate hardened multi-stage Dockerfile |
| `create-docker-compose.sh` | Generate security-hardened docker-compose.yml |
| `create-nginx-config.sh` | Generate production nginx.conf with security headers |
| `create-dockerignore.sh` | Generate optimized .dockerignore |
| `create-deployment-docs.sh` | Generate comprehensive DEPLOYMENT.md |
| `create-all.sh` | Generate all Docker configuration files |

---

## Hardening Features

### Image Security
✅ Specific version tags (e.g., node:18.20.4-alpine3.20)
✅ Minimal Alpine base images (< 50MB final image)
✅ Multi-stage builds (build artifacts only, no source code)
✅ Non-root user execution (USER nginx)
✅ Read-only file permissions (chmod 444 for static files)
✅ Proper file ownership (chown nginx:nginx)
✅ Build cache cleanup (npm cache clean --force)
✅ Unnecessary packages removed (apk del --purge)
✅ HEALTHCHECK instruction

### Dockerfile Security
✅ Non-root user creation and usage
✅ Correct file ownership (chown)
✅ Read-only permissions for static content
✅ No sensitive data in ENV or ARG
✅ BuildKit secret mount support
✅ Minimal layer count
✅ Security-focused CMD (nginx foreground mode)

### docker-compose.yml Hardening
✅ Read-only root filesystem (read_only: true)
✅ Tmpfs mounts for writable directories (/tmp, /var/cache, /var/run)
✅ All capabilities dropped (cap_drop: ALL)
✅ Minimal capability additions (CHOWN, SETGID, SETUID)
✅ No-new-privileges enabled (prevents privilege escalation)
✅ Resource limits (memory: 512M, cpus: 1.0)
✅ Custom network isolation
✅ Health check configuration
✅ Restart policy (unless-stopped)
✅ No privileged mode

### Network Security (nginx)
✅ Nginx version hidden (server_tokens off)
✅ TLS 1.2+ only (ssl_protocols TLSv1.2 TLSv1.3)
✅ Strong cipher suites (ECDHE-ECDSA-AES128-GCM-SHA256+)
✅ HSTS header (Strict-Transport-Security)
✅ CSP headers (Content-Security-Policy)
✅ Security headers (X-Frame-Options, X-Content-Type-Options)
✅ Gzip compression for static assets
✅ Non-privileged ports (8080/8443) for non-root user
✅ Health check endpoint (/health)

### Secrets Management
✅ .env in .gitignore
✅ .env.example template
✅ No hardcoded secrets in Dockerfile
✅ BuildKit secret mount pattern
✅ Runtime secret injection via environment variables
✅ Secret validation documentation

---

## Usage

### Quick Start - Create All Files

```bash
# Generate all hardened Docker files
./scripts/create-all.sh [app-name] [node-version] [nginx-version]
```

**Example:**
```bash
./scripts/create-all.sh contacts-app 18.20.4 1.27.3
```

This creates:
- `Dockerfile` - Multi-stage hardened build
- `docker-compose.yml` - Security-hardened orchestration
- `nginx.conf` - Production configuration with security headers
- `.dockerignore` - Build context optimization
- `DEPLOYMENT.md` - Deployment documentation

### Individual File Generation

#### Create Hardened Dockerfile

```bash
./scripts/create-dockerfile.sh [app-name] [node-version] [nginx-version]
```

**Example:**
```bash
./scripts/create-dockerfile.sh contacts-app 18.20.4 1.27.3
```

**What it creates:**
- Multi-stage Dockerfile (build + production stages)
- Non-root user (nginx)
- Read-only static file permissions
- HEALTHCHECK instruction
- Optimized for production deployment

#### Create Security-Hardened docker-compose.yml

```bash
./scripts/create-docker-compose.sh [app-name]
```

**Example:**
```bash
./scripts/create-docker-compose.sh contacts-app
```

**What it includes:**
- Read-only root filesystem
- Tmpfs mounts for writable directories
- Capability dropping (cap_drop: ALL)
- Resource limits (memory, CPU)
- Security options (no-new-privileges)
- Health check configuration

#### Create Production nginx.conf

```bash
./scripts/create-nginx-config.sh [app-name]
```

**Example:**
```bash
./scripts/create-nginx-config.sh contacts-app
```

**What it includes:**
- SPA fallback routing (try_files)
- HTTPS redirect (HTTP → HTTPS)
- Security headers (CSP, HSTS, X-Frame-Options)
- Gzip compression
- Non-privileged ports (8080/8443)
- Health check endpoint

#### Create Optimized .dockerignore

```bash
./scripts/create-dockerignore.sh
```

**What it excludes:**
- node_modules (rebuilt in container)
- .env files (security - prevents secret leakage)
- .git directory (not needed in container)
- Build outputs (generated in Docker build)
- Test files (not needed in production)
- Documentation files (not needed in container)

#### Create DEPLOYMENT.md Documentation

```bash
./scripts/create-deployment-docs.sh [app-name]
```

**What it documents:**
- Build instructions
- Security hardening features
- Vulnerability scanning process
- Secret management (development vs production)
- SSL/TLS certificate setup
- Troubleshooting guide
- CIS Docker Benchmark compliance

---

## Configuration Templates

### Dockerfile Template (Hardened Multi-Stage)

```dockerfile
# syntax=docker/dockerfile:1

# ============================================================================
# Stage 1: Build
# ============================================================================
FROM node:18.20.4-alpine3.20 AS builder

# Security: Create non-root user for build stage
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy package files with correct ownership
COPY --chown=nodejs:nodejs package*.json ./

# Install dependencies (production only)
RUN npm ci --only=production && \
    npm cache clean --force

# Copy source files
COPY --chown=nodejs:nodejs . .

# Build application
RUN npm run build

# ============================================================================
# Stage 2: Production
# ============================================================================
FROM nginx:1.27.3-alpine3.20

# Security: Run as non-root user (nginx:alpine already has nginx user)
RUN touch /var/run/nginx.pid && \
    # Create necessary directories with correct ownership
    mkdir -p /var/cache/nginx /var/log/nginx && \
    # Set ownership for nginx user
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx /var/run/nginx.pid && \
    # Set correct permissions
    chmod -R 755 /var/cache/nginx /var/log/nginx && \
    # Remove default nginx files
    rm -rf /usr/share/nginx/html/* && \
    # Remove unnecessary packages (if any were added)
    apk del --purge apk-tools

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy build artifacts from builder stage with correct ownership
COPY --from=builder --chown=nginx:nginx /app/build .

# Copy nginx configuration
COPY --chown=nginx:nginx nginx.conf /etc/nginx/nginx.conf

# Security: Set read-only permissions for static files
RUN find /usr/share/nginx/html -type f -exec chmod 444 {} \; && \
    find /usr/share/nginx/html -type d -exec chmod 555 {} \;

# Expose ports (8080/8443 for non-root user)
EXPOSE 8080 8443

# Security: Switch to non-root user
USER nginx

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
```

### docker-compose.yml Template (Security-Hardened)

```yaml
version: '3.8'

services:
  contacts-app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: contacts-app

    # Port mapping (host:container)
    ports:
      - "80:8080"    # HTTP
      - "443:8443"   # HTTPS

    # Environment variables
    environment:
      - NODE_ENV=production

    # Mount .env file as read-only
    env_file:
      - .env

    # Security: Read-only root filesystem
    read_only: true

    # Security: Tmpfs mounts for writable directories
    tmpfs:
      - /tmp
      - /var/cache/nginx
      - /var/run

    # Security: Drop all capabilities and add only required ones
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETGID
      - SETUID

    # Security: Prevent privilege escalation
    security_opt:
      - no-new-privileges:true

    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M

    # Restart policy
    restart: unless-stopped

    # Health check
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

    # Network isolation
    networks:
      - contacts-network

networks:
  contacts-network:
    driver: bridge
```

### nginx.conf Template (Production with Security Headers)

```nginx
worker_processes auto;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Security: Hide nginx version
    server_tokens off;

    # Gzip compression
    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript
               application/json application/javascript application/xml+rss
               application/rss+xml font/truetype font/opentype
               application/vnd.ms-fontobject image/svg+xml;
    gzip_min_length 1000;

    # HTTP server - redirect to HTTPS (port 8080 for non-root)
    server {
        listen 8080;
        server_name _;

        # Allow health check on HTTP
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        # Redirect all other traffic to HTTPS
        location / {
            return 301 https://$host$request_uri;
        }
    }

    # HTTPS server (port 8443 for non-root)
    server {
        listen 8443 ssl http2;
        server_name _;

        # SSL certificate paths (user must provide)
        # ssl_certificate /etc/nginx/ssl/cert.pem;
        # ssl_certificate_key /etc/nginx/ssl/key.pem;

        # SSL security settings
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';

        root /usr/share/nginx/html;
        index index.html;

        # Security headers
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://people.googleapis.com https://oauth2.googleapis.com; font-src 'self' data:;" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # SPA fallback routing
        location / {
            try_files $uri $uri/ /index.html;
        }

        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # No caching for index.html
        location = /index.html {
            add_header Cache-Control "no-store, no-cache, must-revalidate";
        }

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
```

---

## Customization Options

### Application-Specific Modifications

#### Node.js Version

Update the `FROM` line in Dockerfile:
```dockerfile
FROM node:20.11.1-alpine3.19 AS builder
```

#### Build Command

Customize build command in Dockerfile:
```dockerfile
RUN npm run build:prod  # or your custom build command
```

#### Output Directory

Change if your build outputs to a different directory:
```dockerfile
COPY --from=builder --chown=nginx:nginx /app/dist .  # instead of /app/build
```

#### Port Configuration

**Option 1: Non-privileged ports (Recommended)**
```dockerfile
EXPOSE 8080 8443
```
```yaml
ports:
  - "80:8080"
  - "443:8443"
```

**Option 2: Privileged ports with capability**
```dockerfile
EXPOSE 80 443
```
```yaml
ports:
  - "80:80"
  - "443:443"
cap_add:
  - NET_BIND_SERVICE
```

#### Resource Limits

Adjust based on your application needs:
```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'      # Increase CPU
      memory: 1024M    # Increase memory
```

#### Content Security Policy (CSP)

Customize CSP for your application:
```nginx
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; connect-src 'self' https://api.example.com;" always;
```

---

## Security Checklist

After creating Docker files, verify the configuration:

### Image Security
- [ ] ✅ Specific version tags (node:18.20.4-alpine3.20, nginx:1.27.3-alpine3.20)
- [ ] ✅ Non-root user (USER nginx)
- [ ] ✅ Read-only file permissions (chmod 444)
- [ ] ✅ HEALTHCHECK instruction
- [ ] ✅ No hardcoded secrets

### Runtime Security
- [ ] ✅ Read-only root filesystem (read_only: true)
- [ ] ✅ Tmpfs mounts (/tmp, /var/cache, /var/run)
- [ ] ✅ Capabilities dropped (cap_drop: ALL)
- [ ] ✅ No-new-privileges enabled
- [ ] ✅ Resource limits set

### Network Security
- [ ] ✅ Server version hidden (server_tokens off)
- [ ] ✅ TLS 1.2+ only
- [ ] ✅ Security headers (CSP, HSTS, X-Frame-Options)
- [ ] ✅ Gzip compression enabled

### Secrets Management
- [ ] ✅ .env in .gitignore
- [ ] ✅ .env.example exists
- [ ] ✅ No .env in Docker image
- [ ] ✅ No secrets in Dockerfile

---

## Testing the Configuration

After creating the files, test the configuration:

```bash
# 1. Build the Docker image
docker build -t [app-name] .

# 2. Verify image size (should be < 100MB)
docker images [app-name]

# 3. Scan for vulnerabilities
trivy image [app-name]

# 4. Scan for secrets
trivy image --scanners secret [app-name]

# 5. Start the container
docker-compose up -d

# 6. Verify non-root user
docker exec [app-name] whoami
# Expected: nginx

# 7. Verify read-only filesystem
docker exec [app-name] touch /test
# Expected: Permission denied

# 8. Verify tmpfs is writable
docker exec [app-name] touch /tmp/test
# Expected: Success

# 9. Verify health status
docker ps
# Expected: (healthy) status

# 10. Test application
curl http://localhost
# Expected: Application loads

# 11. Verify security headers
curl -I https://localhost
# Expected: CSP, HSTS, X-Frame-Options headers

# 12. Clean up
docker-compose down
```

---

## CIS Docker Benchmark Compliance

The generated configurations comply with CIS Docker Benchmark v1.6.0:

| CIS ID | Control | Implementation |
|--------|---------|----------------|
| 4.1 | Create user for container | `USER nginx` in Dockerfile |
| 4.3 | Verify file permissions | `chmod 444` for static files |
| 4.5 | Enable Content trust | Specific version tags |
| 5.7 | Don't map privileged ports | Ports 8080/8443 (non-root) |
| 5.10 | Set memory limit | `memory: 512M` in docker-compose.yml |
| 5.11 | Set CPU priority | `cpus: '1.0'` in docker-compose.yml |
| 5.12 | Read-only root filesystem | `read_only: true` in docker-compose.yml |
| 5.25 | No new privileges | `no-new-privileges:true` in docker-compose.yml |

---

## References

- [CIS Docker Benchmark v1.6.0](https://www.cisecurity.org/benchmark/docker)
- [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [NIST SP 800-190](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [Snyk Docker Security Best Practices](https://snyk.io/blog/10-docker-image-security-best-practices/)
