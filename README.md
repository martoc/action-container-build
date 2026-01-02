[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# action-container-build

A GitHub Action that builds and pushes container images to Docker Hub, AWS ECR, and GCP Artifact Registry. Supports multi-platform builds (linux/arm64, linux/amd64) using Docker buildx and automatically applies OCI-compliant container labels.

## Features

- Multi-registry support: Docker Hub, AWS ECR, GCP Artifact Registry
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
| `registry` | Registry to push to (`docker.io`, `gcp`, `aws`) | No | `docker.io` |
| `region` | Region for GCP or AWS | No | `""` |
| `repository_name` | Repository name | No | `""` |
| `aws_account_id` | AWS Account ID | No | `""` |
| `gcp_project_id` | Google Cloud Project ID | No | `""` |
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
