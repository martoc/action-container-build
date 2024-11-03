# Usage 

This USAGE.md file describes how to utilise the `martoc/action-tag` GitHub Action, 
which automatically tags your repository based on the commit messages, 
following the Conventional Commits specification.

## Overview

The `martoc/action-tag action` is used to calculate and apply semantic version tags to your GitHub repository. 
This versioning follows the Conventional Commits specification, 
making it easier to maintain an organised and predictable version history.

## Prerequisites

* Ensure your project utilises the Conventional Commits format. The versioning follows the rules of semantic versioning, incrementing:
* `MAJOR` version when a breaking change is introduced.
* `MINOR` version when a new feature is added that is backward-compatible.
* `PATCH` version for backward-compatible bug fixes.

## Basic Usage

Below is an example of how to use martoc/action-tag in your GitHub Actions workflow:

```yaml
name: Tagging Workflow

on:
  push:
    branches:
      - main

jobs:
  tag:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Tag
        uses: martoc/action-tag@v0
```

### Explanation

* The Tagging Workflow is triggered on every push to the main branch.
* The actions/checkout step ensures the repository’s content is checked out so the action can access the commit history.
* The martoc/action-tag@v0 step calculates the semantic version based on the latest commit message and prepares to apply a new tag.

## Optional: Skip Pushing the Tag to the Repository

By default, the action is configured to calculate the semantic version and push the tag to the repository. However, 
you can prevent the action from updating the repository by using the skip-push option.

Usage with skip-push
```yaml
name: Tagging Workflow (Skip Push)

on:
  push:
    branches:
      - main

jobs:
  tag:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Tag
        uses: martoc/action-tag@v0
        with:
          skip-push: true
```
### Explanation

* **skip-push:** true prevents the new tag from being pushed to the repository,
making the action only calculate the tag version without updating the repository.

## Configuration Options

* **skip-push:** (Optional) When set to true, the action calculates the version tag but does not push it to the repository.
Default is `false`.

## Troubleshooting

If the action does not behave as expected:

* Verify that your commit messages follow the Conventional Commits format.
* Check the action logs for detailed error information.
* Ensure that skip-push is set correctly based on whether you want to push tags or not.

## Additional Resources

* [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
* [Semantic Versioning](https://semver.org/)
