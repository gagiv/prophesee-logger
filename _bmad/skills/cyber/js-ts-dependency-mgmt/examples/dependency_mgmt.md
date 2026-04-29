# JS/TS Dependency Management Examples

### 1. Secure `package.json` Structure
**Good Pattern:**
```json
{
  "name": "secure-app",
  "version": "1.0.0",
  "dependencies": {
    "axios": "1.6.2",        // Pinned version
    "express": "4.18.2"      // Pinned version
  },
  "devDependencies": {
    "typescript": "5.3.2",
    "jest": "29.7.0",
    "eslint": "8.54.0"
  }
}
```

### 2. Standardized `.npmrc`
```text
# Enforce exact version saving by default
save-exact=true

# Ensure every developer uses the same registry
registry=https://registry.npmjs.org/

# Forbid scrips for security during install if possible
# ignore-scripts=true
```

### 3. Managing Scoped/Private Packages
If you use a private registry (like Artifactory or GitHub Packages):
```text
@my-org:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
```

### 4. Dependency Auditing Workflow
**Routine Check:**
```bash
# Check for vulnerabilities
npm audit

# Fix minor issues automatically
npm audit fix

# Check for outdated packages without installing
npx npm-check-updates
```

### 5. Cleaning up Node Modules
```bash
# Remove unused dependencies
npm prune

# Clean install (deletes node_modules and installs from lockfile)
npm ci
```
