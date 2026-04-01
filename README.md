# DevOps Technical Task

## Overview

This technical task allows you to demonstrate your DevOps and troubleshooting skills. The exercise should take no more than a weekend to complete. If you need any clarification, please don't hesitate to ask.

## Scenario

This repository contains a .NET service that serves a single endpoint: `/count`. Each call to this endpoint increments a counter and returns the number of times the endpoint has been called.

A previous engineer left the project in an incomplete state. There are issues across the application code, container configuration, and deployment pipelines that need to be resolved before the application can be deployed successfully.

## Task Details

### 1. Fix the Application

The `/count` endpoint has a reported bug — users are seeing unexpected counter values on their first call. Investigate the issue, identify the root cause, and fix it. Ensure your fix is covered by appropriate tests.

### 2. Infrastructure as Code

Write [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview) templates to provision the necessary Azure resources. Place these in the `iac/` folder. At minimum, your infrastructure should include:

- App Service Plan (Linux)
- App Service configured for Docker container deployment
- Application Insights

### 3. Create CI/CD Pipelines

Create Azure DevOps pipeline definitions to build and deploy the application:

- **CI pipeline** (`azure-build.yml`): should test, build, and publish the application (Docker image)
- **CD pipeline** (`azure-release.yml`): should be automatically triggered when CI completes and deploy both the infrastructure (Bicep) and the application
- Include best practices for PR workflows, CI/CD triggers, and approval gates

### 4. Troubleshoot Connectivity

Once deployed, ensure the application is reachable and the `/count` endpoint returns correct values.

## Requirements

- Solution pushed to a public GitHub or Azure DevOps repository
- Working Bicep templates for all Azure infrastructure (do **not** use ARM JSON templates)
- Working CI and CD pipelines implemented as two separate pipeline files
- A readme documenting:
  - Bugs found and how you fixed them
  - Infrastructure design decisions
  - Any trade-offs or assumptions made

## Notes

- If you have any questions, please do not hesitate to ask
