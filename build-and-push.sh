#!/bin/bash
set -e

# Configuration (override via environment variables)
REGISTRY="${REGISTRY:-your-registry.example.com}"
PROJECT="${PROJECT:-affine}"
IMAGE_NAME="${IMAGE_NAME:-affine}"
VERSION="${VERSION:-0.25.5-no-telemetry}"
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
echo "Building everything inside Docker for linux/amd64..."
echo "This will take 10-15 minutes..."
echo ""

# Ensure buildx is available
if ! docker buildx version &> /dev/null; then
  echo "❌ docker buildx is not available. Please install Docker Desktop."
  exit 1
fi

# Create or use buildx builder
if ! docker buildx ls | grep -q "affine-builder"; then
  echo "Creating buildx builder instance..."
  docker buildx create --name affine-builder --use --bootstrap
else
  docker buildx use affine-builder
fi

# Build image
docker buildx build \
  --platform linux/amd64 \
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
  --load \
  .

echo ""
echo "✅ Build complete!"
echo ""

# Verify architecture
echo "Verifying image architecture..."
docker inspect "${FULL_IMAGE}" | grep -A 1 '"Architecture"'
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
