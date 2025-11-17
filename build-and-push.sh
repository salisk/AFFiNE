#!/bin/bash
set -e

# Configuration (override via environment variables)
REGISTRY="${REGISTRY:-your-registry.example.com}"
PROJECT="${PROJECT:-affine}"
IMAGE_NAME="${IMAGE_NAME:-affine-no-telemetry}"
VERSION="${VERSION:-0.25.4-no-telemetry}"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

FULL_IMAGE="${REGISTRY}/${PROJECT}/${IMAGE_NAME}:${VERSION}"
LATEST_IMAGE="${REGISTRY}/${PROJECT}/${IMAGE_NAME}:latest"
GIT_IMAGE="${REGISTRY}/${PROJECT}/${IMAGE_NAME}:${VERSION}-${GIT_HASH}"

echo "=========================================="
echo "Building AFFiNE Self-Hosted (No Telemetry)"
echo "=========================================="
echo "Registry:  ${REGISTRY}"
echo "Project:   ${PROJECT}"
echo "Image:     ${IMAGE_NAME}"
echo "Version:   ${VERSION}"
echo "Git Hash:  ${GIT_HASH}"
echo ""
echo "Tags:"
echo "  - ${FULL_IMAGE}"
echo "  - ${LATEST_IMAGE}"
echo "  - ${GIT_IMAGE}"
echo ""

# Check if logged in
echo "[1/6] Checking registry authentication..."
if ! docker login ${REGISTRY} 2>/dev/null; then
  echo ""
  echo "❌ Not logged in to registry!"
  echo ""
  echo "Please login first:"
  echo "  docker login ${REGISTRY}"
  echo ""
  exit 1
fi
echo "✅ Authenticated"
echo ""

# Build frontend and backend
echo "[2/6] Installing dependencies..."
yarn install

echo "[3/6] Building @affine/web (frontend)..."
yarn affine @affine/web build

echo "[4/6] Building @affine/admin (admin panel)..."
yarn affine @affine/admin build

echo "[5/6] Building @affine/server (backend)..."
# Build backend reader
yarn workspace @affine/reader build
# Build server
yarn workspace @affine/server build

# Prepare for Docker build
echo "[6/6] Preparing Docker build context..."
# Install production dependencies
yarn config set --json supportedArchitectures.cpu '["x64", "arm64", "arm"]'
yarn config set --json supportedArchitectures.libc '["glibc"]'
yarn workspaces focus @affine/server --production

# Generate Prisma client
yarn workspace @affine/server prisma generate

# Move node_modules to server package (required by Dockerfile)
mv ./node_modules ./packages/backend/server/

# Create empty mobile dist (not needed for server deployment)
mkdir -p ./packages/frontend/apps/mobile/dist

echo "Building Docker image..."
docker build \
  --file .github/deployment/node/Dockerfile \
  --tag "${FULL_IMAGE}" \
  --tag "${LATEST_IMAGE}" \
  --tag "${GIT_IMAGE}" \
  --label "org.opencontainers.image.created=${BUILD_DATE}" \
  --label "org.opencontainers.image.version=${VERSION}" \
  --label "org.opencontainers.image.revision=${GIT_HASH}" \
  --label "org.opencontainers.image.title=AFFiNE Self-Hosted (No Telemetry)" \
  --label "org.opencontainers.image.description=AFFiNE self-hosted with all telemetry removed" \
  --progress=plain \
  .

echo ""
echo "✅ Build complete!"
echo ""

# Push images
read -p "Push images to registry? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Pushing images..."
  docker push "${FULL_IMAGE}"
  docker push "${LATEST_IMAGE}"
  docker push "${GIT_IMAGE}"
  echo ""
  echo "✅ Push complete!"
else
  echo "Skipping push. Images are available locally."
fi
echo ""
