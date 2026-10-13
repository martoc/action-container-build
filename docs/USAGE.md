# Usage

## Overview

This GitHub Action is designed to build and push container images to Docker Hub,
AWS Elastic Container Registry (ECR), and Google Cloud Artifact Registry.
It simplifies the CI/CD workflow by automating the process of tagging, building,
and pushing container images across multiple container registries.

## Prerequisites

Secrets Configuration

Before using this action, ensure that you have the following secrets configured in your GitHub repository:

### Docker Hub

* **DOCKER_USERNAME:** Your Docker Hub username.
* **DOCKER_PASSWORD:** Your Docker Hub password or personal access token.

### AWS ECR

* **AWS_ROLE_TO_ASSUME:** The ARN of the AWS role to assume for authentication.

### GCP Artifact Registry

* **GCP_WORKLOAD_IDENTITY_PROVIDER:** Workload identity provider for GCP authentication.
* **GCP_SERVICE_ACCOUNT:** The email of the service account to use for GCP authentication.

### Azure Container Registry

No secret. The action logs in with `azure/login` through OpenID Connect as the identity named by
`azure_client_id`: a user-assigned managed identity holding `AcrPush` on the registry, with a
federated identity credential that trusts the repository's GitHub Actions tokens (for `nodals-ai`
that is `id-github-acr-push`, created by `terraform-azure-deployments-configuration`, whose
federated credentials match every repository of the organisation on `main` and `release/*`).
The job needs `permissions: id-token: write`. The tenant and subscription ids are not secret and
can be organisation variables.

## Inputs

### Action Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `registry` | Registry to push the container to. Valid values: `docker.io`, `gcp`, `aws`, `azure` | No | `docker.io` |
| `region` | Region to push the container to. Valid for GCP or AWS regions | No | `""` |
| `repository_name` | Repository name | No | `""` |
| `aws_account_id` | AWS Account ID | No | `""` |
| `gcp_project_id` | Google Cloud Project ID | No | `""` |
| `azure_registry` | Login server of the Azure Container Registry (e.g. `nodalsai.azurecr.io`). Required with `registry: azure` and with `mirror_registry: azure` | No | `""` |
| `azure_client_id` | Client id of the Entra ID identity the workflow logs in as through OIDC. Required with `registry: azure` and with `mirror_registry: azure` | No | `""` |
| `azure_tenant_id` | Entra ID tenant of that identity | No | `""` |
| `azure_subscription_id` | Azure subscription holding the registry | No | `""` |
| `mirror_registry` | In `manifest` mode only: a second registry that receives a copy of the manifest list just pushed, under the same repository and tags. Valid values: `azure`. The copy is made with `docker buildx imagetools create` from the primary registry; nothing is rebuilt, and the version tag is locked on the mirror after the copy | No | `""` |
| `platforms` | Platforms to build for (e.g., `linux/amd64`, `linux/arm64`) | No | `linux/arm64,linux/amd64` |
| `build_args` | Additional build arguments to pass to docker build | No | `""` |
| `mode` | Build mode: `build` (default), `multi-arch` (native single-arch build with arch-suffixed tag), `manifest` (create manifest list from arch-suffixed images). `multi-arch` and `manifest` are for the `aws` and `azure` registries. | No | `"build"` |

### Environment Variables

The following environment variables can be used to customize the build:

| Variable | Description | Required |
|----------|-------------|----------|
| `TAG_VERSION` | The version tag for the container image | Yes |
| `DOCKER_USERNAME` | Docker Hub username (required for docker.io registry) | Conditional |
| `DOCKER_PASSWORD` | Docker Hub password (required for docker.io registry) | Conditional |
| `PLATFORMS` | Override the platforms input | No |
| `DOCKERFILE` | Path to the Dockerfile (default: `Dockerfile`) | No |
| `WORKDIR` | Working directory for the build (default: `.`) | No |
| `NAMESPACE` | Namespace for Docker Hub (deprecated, use `repository_name` input) | No |
| `DESCRIPTION` | Description for container labels (default: first line of commit message) | No |

## Example

Here are examples of how to use this GitHub Action to build and push container
images to Docker Hub, AWS ECR, and GCP Artifact Registry.

```yaml
name: Integration Tests

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  docker:
    permissions:
      contents: write
      id-token: write
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 50
          fetch-tags: true
      - name: Tag
        uses: martoc/action-tag@v0
        with:
          skip-push: true
      - name: Build & Push Container Image
        uses: martoc/action-container-build@v0
        env:
          DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
          DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}

  aws:
    permissions:
      contents: write
      id-token: write
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 50
          fetch-tags: true
      - name: Tag
        uses: martoc/action-tag@v0
        with:
          skip-push: true
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v6
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
          role-session-name: github-actions
          aws-region: us-east-2
      - name: Build & Push Container Image
        uses: martoc/action-container-build@v0
        with:
          registry: aws
          region: us-east-2
          repository_name: repo
          aws_account_id: 123456789012

  gcp:
    permissions:
      contents: write
      id-token: write
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 50
          fetch-tags: true
      - name: Tag
        uses: martoc/action-tag@v0
        with:
          skip-push: true
      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
          service_account: ${{ secrets.GCP_SERVICE_ACCOUNT }}
      - name: Build & Push Container Image
        uses: martoc/action-container-build@v0
        with:
          registry: gcp
          region: europe-west2
          repository_name: repository
          gcp_project_id: project-id

  multi-platform:
    permissions:
      contents: write
      id-token: write
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 50
          fetch-tags: true
      - name: Tag
        uses: martoc/action-tag@v0
        with:
          skip-push: true
      - name: Build & Push Container Image (ARM64 only)
        uses: martoc/action-container-build@v0
        env:
          DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
          DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
        with:
          platforms: linux/arm64

  with-build-args:
    permissions:
      contents: write
      id-token: write
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 50
          fetch-tags: true
      - name: Tag
        uses: martoc/action-tag@v0
        with:
          skip-push: true
      - name: Build & Push Container Image with build args
        uses: martoc/action-container-build@v0
        env:
          DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
          DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
        with:
          build_args: --build-arg MY_ARG=value
```

## Native Multi-Architecture Builds (AWS ECR)

For faster, more reliable multi-architecture builds, you can use native runners for each
architecture instead of QEMU emulation. Each architecture builds on its own dedicated runner,
then a final job creates a Docker manifest list combining them.

This follows the pattern described in the
[AWS ECR documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-multi-architecture-image.html).

```yaml
name: Native Multi-Arch Build

on:
  push:
    branches:
      - main

jobs:
  build-arm64:
    permissions:
      contents: write
      id-token: write
    runs-on: ubuntu-24.04-arm
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 50
          fetch-tags: true
      - name: Tag
        uses: martoc/action-tag@v0
        with:
          skip-push: true
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v6
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
          role-session-name: github-actions
          aws-region: us-east-2
      - name: Build & Push ARM64 Image
        uses: martoc/action-container-build@v0
        with:
          registry: aws
          region: us-east-2
          repository_name: repo
          aws_account_id: 123456789012
          platforms: linux/arm64
          mode: multi-arch

  build-amd64:
    permissions:
      contents: write
      id-token: write
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 50
          fetch-tags: true
      - name: Tag
        uses: martoc/action-tag@v0
        with:
          skip-push: true
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v6
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
          role-session-name: github-actions
          aws-region: us-east-2
      - name: Build & Push AMD64 Image
        uses: martoc/action-container-build@v0
        with:
          registry: aws
          region: us-east-2
          repository_name: repo
          aws_account_id: 123456789012
          platforms: linux/amd64
          mode: multi-arch

  create-manifest:
    permissions:
      contents: write
      id-token: write
    needs: [build-arm64, build-amd64]
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 50
          fetch-tags: true
      - name: Tag
        uses: martoc/action-tag@v0
        with:
          skip-push: true
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v6
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
          role-session-name: github-actions
          aws-region: us-east-2
      - name: Create Manifest List
        uses: martoc/action-container-build@v0
        with:
          registry: aws
          region: us-east-2
          repository_name: repo
          aws_account_id: 123456789012
          platforms: linux/arm64,linux/amd64
          mode: manifest
```

## Registry-Specific Requirements

### Docker Hub

* `DOCKER_USERNAME` and `DOCKER_PASSWORD` environment variables must be set
* `repository_name` input or `NAMESPACE` environment variable should be set (defaults to GitHub repository owner)

### AWS ECR

* `registry` input must be set to `aws`
* `region` input is required
* `repository_name` input is required
* `aws_account_id` input is required
* AWS credentials must be configured (e.g., using `aws-actions/configure-aws-credentials`)

### GCP Artifact Registry

* `registry` input must be set to `gcp`
* `region` input is required
* `repository_name` input is required
* `gcp_project_id` input is required
* GCP authentication must be configured (e.g., using `google-github-actions/auth`)

### Azure Container Registry

* `registry` input must be set to `azure`
* `azure_registry` input is required (the login server); `region` is not used, the registry's
  replicas answer the one login server
* `repository_name` input is required
* `azure_client_id`, `azure_tenant_id` and `azure_subscription_id` identify the identity the
  action logs in as; the job needs `permissions: id-token: write`
* Images are tagged `<azure_registry>/<repository_name>/<name>:<tag>`, the same layout as ECR

### Mirroring a manifest list to Azure

In `manifest` mode, `mirror_registry: azure` copies the manifest list just created in the
primary registry to the Azure registry, with the same `azure_*` inputs as above:

```yaml
- name: Create Manifest List
  uses: martoc/action-container-build@v0
  with:
    platforms: linux/arm64,linux/amd64
    registry: aws
    region: eu-central-1
    repository_name: data-platform
    aws_account_id: "051942114282"
    mode: manifest
    mirror_registry: azure
    azure_registry: nodalsai.azurecr.io
    azure_client_id: ${{ vars.AZURE_ACR_PUSH_CLIENT_ID }}
    azure_tenant_id: ${{ vars.AZURE_TENANT_ID }}
    azure_subscription_id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
```

Both registries then hold identical digests for `<repository_name>/<name>:<TAG_VERSION>` and
`:latest`. The version tag is locked on the Azure side (`az acr repository update
--write-enabled false`), the counterpart of ECR's immutable tags. A registry that is not `aws`
cannot be the primary of a mirror: `manifest` mode exists for `aws` and `azure` only, and
mirroring Azure to itself is refused.

## Container Labels

The action automatically adds the following labels to the container image:

* `org.label-schema.*` labels (legacy)
* `org.opencontainers.image.*` labels (OCI standard)

These labels include information such as:

* Image name and version
* Source repository URL
* Build date and commit SHA
* Description and documentation links
