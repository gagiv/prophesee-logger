#!/bin/bash
#
# create-all.sh
# Creates all hardened Docker configuration files
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="${1:-contacts-app}"
NODE_VERSION="${2:-18.20.4-alpine3.20}"
NGINX_VERSION="${3:-1.27.3-alpine3.20}"

echo -e "${BLUE}🐳 Creating Hardened Docker Configuration${NC}"
echo -e "${BLUE}==========================================${NC}"
echo "Application: $APP_NAME"
echo "Node version: $NODE_VERSION"
echo "Nginx version: $NGINX_VERSION"
echo ""

# Check if files exist and warn
check_file() {
    if [ -f "$1" ]; then
        echo -e "${YELLOW}⚠️  Warning: $1 already exists${NC}"
        read -p "   Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    return 0
}

# ============================================================================
# Create Dockerfile
# ============================================================================
echo -e "${BLUE}Creating Dockerfile...${NC}"

if check_file "Dockerfile"; then
cat > Dockerfile << 'EOF'
# syntax=docker/dockerfile:1
# @fileoverview Multi-stage hardened Dockerfile for production deployment
# @module Dockerfile

# ============================================================================
# Stage 1: Build
# ============================================================================
FROM node:NODE_VERSION AS builder

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
FROM nginx:NGINX_VERSION

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
EOF

    # Replace placeholders
    sed -i "s/NODE_VERSION/$NODE_VERSION/g" Dockerfile
    sed -i "s/NGINX_VERSION/$NGINX_VERSION/g" Dockerfile

    echo -e "${GREEN}✅ Created Dockerfile${NC}"
fi

# ============================================================================
# Create docker-compose.yml
# ============================================================================
echo -e "${BLUE}Creating docker-compose.yml...${NC}"

if check_file "docker-compose.yml"; then
cat > docker-compose.yml << EOF
version: '3.8'

services:
  ${APP_NAME}:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ${APP_NAME}

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
      - ${APP_NAME}-network

networks:
  ${APP_NAME}-network:
    driver: bridge
EOF

    echo -e "${GREEN}✅ Created docker-compose.yml${NC}"
fi

# ============================================================================
# Create nginx.conf
# ============================================================================
echo -e "${BLUE}Creating nginx.conf...${NC}"

if check_file "nginx.conf"; then
cat > nginx.conf << 'EOF'
# @fileoverview Production nginx configuration with security hardening
# @module nginx.conf

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
EOF

    echo -e "${GREEN}✅ Created nginx.conf${NC}"
fi

# ============================================================================
# Create .dockerignore
# ============================================================================
echo -e "${BLUE}Creating .dockerignore...${NC}"

if check_file ".dockerignore"; then
cat > .dockerignore << 'EOF'
# Dependencies (will be installed via npm ci)
node_modules/
npm-debug.log*
yarn.lock
package-lock.json

# Build outputs (will be generated in Docker build)
build/
dist/
.cache/

# Environment files (security - never bake into image)
.env
.env.local
.env.*.local

# Git (not needed in container)
.git/
.gitignore
.gitattributes

# Tests (not needed in production image)
**/*.test.ts
**/*.test.tsx
**/*.test.js
**/*.test.jsx
**/__tests__/
coverage/
.nyc_output/

# Documentation (not needed in container)
*.md
docs/
CHANGELOG
LICENSE

# IDE files (not needed in container)
.vscode/
.idea/
*.swp
*.swo
*.sublime-*

# CI/CD (not needed in container)
.github/
.gitlab-ci.yml
.travis.yml
Jenkinsfile

# Storybook (not needed in production)
.storybook/
storybook-static/

# Misc
.DS_Store
Thumbs.db
*.log
tmp/
temp/

# Docker files (already in context)
Dockerfile*
docker-compose*.yml
.dockerignore

# Agent files (not needed in container)
.agent/
_bmad-output/
EOF

    echo -e "${GREEN}✅ Created .dockerignore${NC}"
fi

# ============================================================================
# Create .env.example (if doesn't exist)
# ============================================================================
echo -e "${BLUE}Creating .env.example (if not exists)...${NC}"

if [ ! -f ".env.example" ]; then
cat > .env.example << 'EOF'
# Environment Configuration Template
# Copy this file to .env and fill in your actual values
# NEVER commit .env to git!

# Google OAuth Configuration
REACT_APP_GOOGLE_CLIENT_ID=<your-client-id-here>.apps.googleusercontent.com

# API Configuration
REACT_APP_API_BASE_URL=https://people.googleapis.com/v1

# Application Environment
NODE_ENV=production
EOF

    echo -e "${GREEN}✅ Created .env.example${NC}"
else
    echo -e "${YELLOW}   .env.example already exists, skipping${NC}"
fi

# ============================================================================
# Update .gitignore
# ============================================================================
echo -e "${BLUE}Updating .gitignore...${NC}"

if [ -f ".gitignore" ]; then
    if ! grep -q "^\.env$" .gitignore; then
        echo "" >> .gitignore
        echo "# Environment variables (secrets)" >> .gitignore
        echo ".env" >> .gitignore
        echo -e "${GREEN}✅ Added .env to .gitignore${NC}"
    else
        echo -e "${YELLOW}   .env already in .gitignore${NC}"
    fi
else
    cat > .gitignore << 'EOF'
# Environment variables (secrets)
.env

# Dependencies
node_modules/

# Build outputs
build/
dist/

# Logs
*.log
EOF
    echo -e "${GREEN}✅ Created .gitignore${NC}"
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo -e "${GREEN}✅ Hardened Docker configuration created successfully!${NC}"
echo ""
echo "Files created:"
echo "  - Dockerfile (multi-stage, non-root, hardened)"
echo "  - docker-compose.yml (security-hardened)"
echo "  - nginx.conf (production configuration)"
echo "  - .dockerignore (optimized build context)"
echo "  - .env.example (template)"
echo ""
echo "Next steps:"
echo "  1. Copy .env.example to .env and fill in your credentials"
echo "  2. Build the image: docker build -t ${APP_NAME} ."
echo "  3. Scan for vulnerabilities: trivy image ${APP_NAME}"
echo "  4. Start the container: docker-compose up -d"
echo "  5. Verify security: docker exec ${APP_NAME} whoami (should show 'nginx')"
echo ""
echo "To verify hardening, run:"
echo "  ./.agent/develop/verify-hardened-docker-skill/scripts/verify-docker-hardening.sh ${APP_NAME}"
echo ""
