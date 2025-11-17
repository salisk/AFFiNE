# Quick Start: Build & Deploy AFFiNE No-Telemetry

## 🚀 Build & Push

```bash
# 1. Set your registry details
export REGISTRY="your-registry.example.com"
export PROJECT="affine"
export IMAGE_NAME="affine-no-telemetry"

# 2. Login to your registry
docker login ${REGISTRY}

# 3. Build and push (takes 10-20 minutes)
./build-and-push.sh
```

## 📝 Update Your Flux HelmRelease

Replace the image sections in your HelmRelease:

```yaml
# Change from:
image:
  repository: ghcr.io/toeverything/affine
  tag: 0.25.4

# To:
image:
  repository: your-registry.example.com/affine/affine-no-telemetry
  tag: 0.25.4-no-telemetry
```

Update **both** places:
- `initContainers.init-config.image`
- `containers.app.image`

## 🔄 Deploy

```bash
flux reconcile helmrelease affine -n <namespace>
```

## ✅ Verify No Telemetry

Open DevTools → Network tab and filter for:
- ❌ `telemetry.affine.run` - Should NOT appear
- ❌ `affine.run` - Should NOT appear
- ❌ `sentry.io` - Should NOT appear

## 📖 Full Documentation

See [BUILD-SELFHOSTED.md](./BUILD-SELFHOSTED.md) for complete instructions.
