[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# action-container-build

A GitHub Action that builds and pushes container images to Docker Hub, AWS ECR, GCP Artifact Registry and Azure Container Registry. Supports multi-platform builds (linux/arm64, linux/amd64) using Docker buildx and automatically applies OCI-compliant container labels.

## Features

- Multi-registry support: Docker Hub, AWS ECR, GCP Artifact Registry, Azure Container Registry
- Mirroring: in `manifest` mode the finished manifest list can be copied to an Azure registry in the same job, so one build serves two clouds
- Multi-platform builds using Docker buildx
- Automatic OCI-compliant container labelling
- Configurable build arguments and platforms

## Quick Start

```yaml
- name: Build & Push Container Image
  uses: martoc/action-container-build@v0
  env:
    DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
    DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

## Documentation

- [Usage Guide](./docs/USAGE.md) - Detailed usage instructions and examples
- [Code Style](./docs/CODESTYLE.md) - Code style guidelines for contributors

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `registry` | Registry to push to (`docker.io`, `gcp`, `aws`, `azure`) | No | `docker.io` |
| `region` | Region for GCP or AWS | No | `""` |
| `repository_name` | Repository name | No | `""` |
| `aws_account_id` | AWS Account ID | No | `""` |
| `gcp_project_id` | Google Cloud Project ID | No | `""` |
| `azure_registry` | Login server of the Azure Container Registry, e.g. `nodalsai.azurecr.io` (`azure` registry and `mirror_registry`) | No | `""` |
| `azure_client_id` | Client id of the identity logged in through OIDC, holding `AcrPush` | No | `""` |
| `azure_tenant_id` | Entra ID tenant of that identity | No | `""` |
| `azure_subscription_id` | Subscription holding the registry | No | `""` |
| `mode` | `build`, `multi-arch` or `manifest` (`aws` and `azure` registries) | No | `build` |
| `mirror_registry` | In `manifest` mode, a second registry that receives a copy of the manifest list: `azure` | No | `""` |
| `platforms` | Build platforms | No | `linux/arm64,linux/amd64` |
| `build_args` | Additional build arguments | No | `""` |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `TAG_VERSION` | Version tag for the container image (required) |
| `DOCKER_USERNAME` | Docker Hub username (required for docker.io) |
| `DOCKER_PASSWORD` | Docker Hub password (required for docker.io) |

## Licence

This project is licenced under the MIT Licence - see the [LICENCE](LICENSE) file for details.
