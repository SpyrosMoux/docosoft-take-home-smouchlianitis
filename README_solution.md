# DevOps Take-Home Solution

## 1. Application Bug: Root Cause and Fix

The `/count` endpoint returned an unexpected value (0) on first call because of how the counter increment was implemented.

- Root cause: the counter logic used a post-increment pattern (`counter++`) in the return path, which returned the pre-increment value (0).
- Considered fix: switch to pre-increment (`++counter`).
- Implemented fix: use a more explicit/readable approach by incrementing first and returning afterwards.

Current implementation in `src/Services/CounterService.cs`:

```csharp
_counter++;
return _counter;
```

Additional behavior:

- Pre-existing tests were also refactored to accommodate this change.
- The previous tests used mocks, which were not suitable for validating this stateful edge case.
- Tests now cover first increment and sequential increment behavior using the concrete service in `tests/CounterAPI.Tests/CountControllerTests.cs`.
- Added a dedicated `/Health` endpoint to support platform and pipeline health validation.
- Added OpenTelemetry instrumentation (Azure Monitor exporter) to improve application observability.

## 2. Infrastructure (Bicep) Design

Infrastructure is implemented in Bicep under `iac/` and is now deployed at **resource-group scope**.

### Core resources provisioned

- Azure Container Registry (`iac/modules/acr.bicep`)
- Linux App Service Plan + Linux App Service (`iac/modules/appservice.bicep`)
- User-assigned managed identity for App Service image pull
- Application Insights
- Log Analytics Workspace
- Diagnostic settings for Web App + ACR
- Action Group + baseline alerts (5xx and latency)
- Pipeline user-assigned managed identity and RBAC (`iac/modules/pipeline-identity.bicep`)

### Security and access decisions

- ACR admin user is disabled.
- App Service pulls from ACR using managed identity (`AcrPull`) rather than registry credentials.
- Pipeline identity is created via IaC and granted:
  - `Contributor` on resource group
  - `User Access Administrator` on resource group (needed for RBAC resources in deployment)
  - `AcrPush` on ACR

### Tagging

Common tags are applied to supported resources:

- `environment: production`
- `owner: smouchlianitis`
- `project: docosoft`

## 3. CI/CD Pipelines

Two Azure DevOps YAML pipelines are included:

Application runtime additions supporting operations and observability:

- Added `/Health` endpoint support for App Service health checks and CD health validation.
- Added OpenTelemetry integration with Azure Monitor export for application telemetry.

- `azure-build.yml` (CI)
  - Triggered on `main`
  - Restores and tests the .NET solution
  - Builds Docker image
  - Pushes image tags:
    - immutable build tag: `counterapi:<Build.BuildId>`
    - rolling tag: `counterapi:latest`

- `azure-release.yml` (CD)
  - Triggered from CI pipeline completion
  - Infra flow split into:
    - `what-if`
    - approval checkpoint
    - apply
  - App flow updates only the container image tag (infra does not own runtime image tag)
  - Health check validates `/Health`
  - Rollback step restores previous image if health check fails

## 4. Trade-offs and Assumptions

### Trade-offs

- ACR public network access is currently enabled to keep delivery flow simple without introducing VNet/private endpoint complexity in this iteration.
- Alerts are intentionally baseline-level and can be tuned further once production telemetry patterns stabilize.
- Deployment slots are not used, to avoid increasing scope and complexity for this exercise.
- The current IaC setup requires either pre-existing resource group creation or a more privileged deployment model (subscription-scope) to create it as part of automation.

### Assumptions

- A single production resource group is used for this exercise.
- Azure DevOps service connection is configured with workload identity federation to the pipeline managed identity.

## 5. Future Improvements

- Add deployment slots (`staging` -> `production`) to enable safer blue/green-style rollouts and near-instant rollbacks.
- Move ACR to private access (private endpoint + private DNS + VNet integration for App Service and pipeline agents).
- Separate pipeline identities and service connections for CI and CD to tighten least-privilege boundaries.
- Extend alerting with service-level objectives and actionable thresholds based on real production baseline data.
- Add automated post-deploy verification for business behavior (beyond health) and publish those checks as release quality gates.
