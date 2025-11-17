# Building AFFiNE Self-Hosted (No Telemetry)

This guide explains how to build a custom AFFiNE Docker image with all telemetry and phone-home behavior removed, and deploy it to your Kubernetes cluster using Flux.

## 🔒 Changes Made

All telemetry and external phone-home behavior has been removed:

- ✅ Mixpanel analytics disabled
- ✅ Sentry error reporting disabled
- ✅ Auto-tracking disabled
- ✅ User data collection disabled
- ✅ AI usage tracking disabled
- ✅ Backend OpenTelemetry disabled
- ✅ HTML preview external requests removed
- ✅ Auto-update checks disabled
- ✅ Onboarding questionnaire disabled
- ✅ All external tracking removed

**Total files modified:** 17

## 📋 Prerequisites

- Docker installed and running
- Node.js 22+ and Yarn
- Git (for version tagging)
- 8GB+ RAM for building
- 20GB+ free disk space
- Access to your container registry

## 🚀 Quick Start

### 1. Configure Registry

```bash
export REGISTRY="your-registry.example.com"
export PROJECT="affine"
export IMAGE_NAME="affine-no-telemetry"
export VERSION="0.25.4-no-telemetry"
```

### 2. Login to Registry

```bash
docker login ${REGISTRY}
```

### 3. Build and Push

```bash
chmod +x build-and-push.sh
./build-and-push.sh
```

This script will:

1. Install dependencies
2. Build frontend (web, admin)
3. Build backend (reader, server)
4. Prepare Docker context
5. Build Docker image using the existing Dockerfile
6. Prompt to push to registry

## 🔧 Build Steps Explained

The `build-and-push.sh` script follows the same process as AFFiNE's CI/CD pipeline:

### 1. Frontend Builds

```bash
yarn affine @affine/web build      # Web application
yarn affine @affine/admin build    # Admin panel
# Mobile web skipped (not needed for server deployment)
```

### 2. Backend Build

```bash
yarn workspace @affine/reader build  # Reader package
yarn workspace @affine/server build  # Server
```

### 3. Docker Context Preparation

```bash
# Install production dependencies for multi-arch
yarn workspaces focus @affine/server --production

# Generate Prisma client
yarn workspace @affine/server prisma generate

# Move node_modules (required by Dockerfile)
mv ./node_modules ./packages/backend/server/
```

### 4. Docker Build

Uses the existing Dockerfile at `.github/deployment/node/Dockerfile`

## 📦 Build Artifacts

The build process creates:

### Frontend Builds

- `packages/frontend/apps/web/dist` - Web application
- `packages/frontend/admin/dist` - Admin panel

### Backend Build

- `packages/backend/server/dist` - Node.js server
- `node_modules` - Production dependencies
- Prisma client generated

**Note:** Mobile web is skipped as it's not needed for server deployments.

## 🐳 Docker Image Details

**Base Image:** `node:22-bookworm-slim`

**Installed Packages:**

- openssl (for Prisma)
- libjemalloc2 (memory allocator)

**Environment:**

- `LD_PRELOAD=libjemalloc.so.2` (enables jemalloc)

**Exposed Port:** 3010

**Health Check:** `/api/healthz` endpoint

**Image Size:** ~800MB (compressed)
