# infra

Azure infrastructure repository for provisioning AKS on Azure using Bicep and Azure Verified Modules (AVM), orchestrated by Azure Pipelines.

## Repository Structure

- `pipelines/` - Parent pipeline entrypoint.
- `templates/` - Bicep and parameter templates (AVM-based).
- `.github/` - GitHub Copilot instructions, custom agent profile, and reusable prompt files.

Agent profiles:

- `.github/agents/devops-expert.agent.md`

Shared pipeline assets are hosted in `infra-pipeline-common`:

- `pipelines/stages/`
- `pipelines/extends/`
- `pipelines/steps/`
- `pipelines/variables/`
- `scripts/`

## Pipeline Design

Primary pipeline definition is at `pipelines/azure-pipelines.yml`.

The parent pipeline passes a `deploymentTemplates` object array into the shared extends template (`pipelines/extends/infra-deploy.yml@pipeline_common`) where each entry contains:

- `name`
- `templateFile`
- `parameterFile`

Validate, What-If, and Deploy execute in loops across this array so multiple resource templates can be processed in one run.

Shared variable templates are stored in repository `infra-pipeline-common`:

- `pipelines/variables/common.yml`
- `pipelines/variables/dev.yml`
- `pipelines/variables/prd.yml`

The pipeline imports `infra-pipeline-common` as an external repository resource (`pipeline_common`) and extends a shared orchestration template from that repository.

Deployment order inside each environment is:

1. `templates/network/network.bicep` (shared VNet + subnets)
2. `templates/loganalytics/loganalytics.bicep` (shared Log Analytics workspace)
3. `templates/acr/acr.bicep` (ACR integrated to shared VNet via private endpoint)
4. `templates/aks/aks.bicep` (managed cluster only, consuming existing VNet and workspace)

The pipeline is split into four ordered stages:

1. **Validate** - Lint/build/validate Bicep.
2. **WhatIf** - Preview Azure changes.
3. **dev-deploy** - Deploy AKS to dev environment.
4. **prd-deploy** - Deploy AKS to prd environment.

During **Validate**, tokenized `.bicepparam` files are transformed per environment and template into generated artifacts that include both `.bicep` and resolved `.bicepparam` files, published as `transformed-<env>-<template>`.
**WhatIf** and **Deploy** download the matching transformed artifact in each template iteration and use those transformed files directly.

The deploy stage template is iterated with a loop over fixed environments (dev then prd), using environment names directly.

Supported deployment environments:

- **dev**
- **prd**

## AVM Modules

This repo currently includes:

- `templates/network/network.bicep` (Virtual Network and subnets)
- `templates/loganalytics/loganalytics.bicep` (Log Analytics workspace)
- `templates/acr/acr.bicep` (Azure Container Registry)
- `br/public:avm/res/container-service/managed-cluster:0.12.0`
- `br/public:avm/res/container-registry/registry:0.10.0`
- `br/public:avm/res/network/virtual-network:0.7.2`
- `br/public:avm/res/operational-insights/workspace:0.15.0`

AKS template now contains only managed cluster deployment logic. Networking and observability prerequisites are deployed independently and consumed as existing resources by AKS and ACR templates.

Network access controls are parameterized per environment:

- AKS API server access is restricted with `apiServerAuthorizedIpRanges`.
- AKS control-plane pricing tier is parameterized with `aksSkuTier` (dev: `Free`, prd: `Standard`).
- ACR SKU is environment-tuned for cost (`Basic` in dev, `Standard` in prd).
- Log Analytics cost controls are parameterized with `logAnalyticsSkuName`, `logAnalyticsRetentionInDays`, and `logAnalyticsDailyQuotaGb` (dev defaults: `PerGB2018`, `30`, `0.5`; prd defaults: `PerGB2018`, `90`, `-1`).
- ACR public endpoint is enabled with selected-network firewall rules via `acrAllowedIpRules`.
- ACR is VNet integrated through a private endpoint on `privateEndpointSubnetName`.

AKS is configured with the AVM `fluxExtension` enabled (`flux-system` release namespace) to support Flux GitOps extension deployment.
Flux extension configuration settings are parameterized via `fluxExtensionConfigurationSettings` (JSON object string), with a safe default of `{}` in `infra-pipeline-common/pipelines/variables/common.yml`.
Flux configurations are parameterized via `fluxConfigurations` and point to `https://github.com/jeevan-spark-org/flux-cd` with `infra` and `apps` kustomizations (`apps` depends on `infra`) for environment-specific paths.
Flux app deployment in this setup expects OCI Helm charts and container images published to environment ACRs, with Flux reconciling those artifacts based on `flux-cd` manifests.

Parameter strategy:

- One shared parameter file: `templates/aks/aks.bicepparam`
- `aks.bicepparam` uses `#{{ variableName }}` placeholders for all parameter values
- Environment-specific values are injected at deploy time from `infra-pipeline-common/pipelines/variables/dev.yml` and `infra-pipeline-common/pipelines/variables/prd.yml` via qetza ReplaceTokens initialization in the deploy stage
- Complex values (arrays/objects/integers) are passed as strings and converted inside Bicep using `json()`/`int()` helper variables
- Network address space (`vnetAddressPrefixes`) is passed as a string token and normalized into an array in `templates/network/network.bicep` before module invocation.
- AKS autoscaling is parameterized separately for system and user node pools (`systemNodePoolEnableAutoScaling`, `userNodePoolEnableAutoScaling`) with separate min/max settings per pool (`systemNodePoolMinCount`, `systemNodePoolMaxCount`, `userNodePoolMinCount`, `userNodePoolMaxCount`).

> Review and update module versions regularly after validation.

## Required Azure DevOps Setup

1. Create an Azure Resource Manager service connection with least privilege.
2. Configure pipeline variables or variable groups:

   - `azureServiceConnection`
   - environment-specific values are provided in `infra-pipeline-common/pipelines/variables/dev.yml` and `infra-pipeline-common/pipelines/variables/prd.yml`

3. Configure environment approvals/checks for deployment environments.

## Security Notes

- Never commit credentials or secrets.
- Use Azure DevOps variable groups/Key Vault-backed secrets.
- Prefer private networking and production-hardening settings for non-dev environments.
