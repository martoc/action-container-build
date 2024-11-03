# Usage

## Overview

This GitHub Action is designed to build and push container images to Docker Hub, 
AWS Elastic Container Registry (ECR), and Google Container Registry (GCR). 
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

### GCP GCR

* **GCP_WORKLOAD_IDENTITY_PROVIDER:** Workload identity provider for GCP authentication.
* **GCP_SERVICE_ACCOUNT:** The email of the service account to use for GCP authentication.

## Example

Here are examples of how to use this GitHub Action to build and push container images to Docker Hub, AWS ECR, and GCP GCR.

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
        uses: ./
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
        uses: ./
        with:
          registry: aws
          region: us-east-2
          repository_name: martoc
          aws_account_id: 637423379760

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
        uses: ./
        with:
          registry: gcp
          region: europe-west2
          repository_name: repository
          gcp_project_id: project-id
```

### Inputs

#### Docker Hub

* DOCKER_USERNAME (required): Your Docker Hub username.
* DOCKER_PASSWORD (required): Your Docker Hub password or access token.

#### AWS

* **registry:** Set to `aws` when pushing to AWS ECR.
* **region (required for AWS):** The AWS region for the ECR registry.
* **repository_name (required for AWS):** The name of the ECR repository.
* **aws_account_id (required for AWS):** Your AWS account ID.

#### GCP

* **registry:** Set to `gcp` when pushing to GCP GCR.
* **region (required for GCP):** The region for the GCR registry.
* **repository_name (required for GCP):** The name of the GCR repository.
* **gcp_project_id (required for GCP):** Your GCP project ID.
