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

## Inputs

### Action Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `registry` | Registry to push the container to. Valid values: `docker.io`, `gcp`, `aws` | No | `docker.io` |
| `region` | Region to push the container to. Valid for GCP or AWS regions | No | `""` |
| `repository_name` | Repository name | No | `""` |
| `aws_account_id` | AWS Account ID | No | `""` |
| `gcp_project_id` | Google Cloud Project ID | No | `""` |
| `platforms` | Platforms to build for (e.g., `linux/amd64`, `linux/arm64`) | No | `linux/arm64,linux/amd64` |
| `build_args` | Additional build arguments to pass to docker build | No | `""` |

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
      - uses: actions/checkout@v4
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
      - uses: actions/checkout@v4
        with:
          fetch-depth: 50
          fetch-tags: true
      - name: Tag
        uses: martoc/action-tag@v0
        with:
          skip-push: true
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
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
      - uses: actions/checkout@v4
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
      - uses: actions/checkout@v4
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
      - uses: actions/checkout@v4
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

## Container Labels

The action automatically adds the following labels to the container image:

* `org.label-schema.*` labels (legacy)
* `org.opencontainers.image.*` labels (OCI standard)

These labels include information such as:

* Image name and version
* Source repository URL
* Build date and commit SHA
* Description and documentation links
