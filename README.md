# infra

Azure infrastructure repository for provisioning AKS on Azure using Bicep and Azure Verified Modules (AVM), orchestrated by Azure Pipelines.

## Repository Structure

- `pipelines/` - Parent and reusable pipeline templates.
- `templates/` - Bicep and parameter templates (AVM-based).
- `scripts/` - Reusable PowerShell scripts for CI/CD operations.
- `.github/` - GitHub Copilot instructions, custom agent profile, and reusable prompt files.

## Pipeline Design

Primary pipeline definition is at `pipelines/azure-pipelines.yml`. The root `azure-pipelines.yml` is a thin wrapper.

The parent pipeline accepts a `deploymentTemplates` object array where each entry contains:
- `name`
- `templateFile`
- `parameterFile`

Validate, What-If, and Deploy execute in loops across this array so multiple resource templates can be processed in one run.

Environment variable templates:
- `pipelines/variables/common.yml`
- `pipelines/variables/dev.yml`
- `pipelines/variables/prd.yml`

The pipeline is split into four ordered stages:
1. **Validate** - Lint/build/validate Bicep.
2. **WhatIf** - Preview Azure changes.
3. **dev-deploy** - Deploy AKS to dev environment.
4. **prd-deploy** - Deploy AKS to prd environment.

The deploy stage template is iterated with a loop over fixed environments (dev then prd), using environment names directly.

Supported deployment environments:
- **dev**
- **prd**

## AVM Modules

This repo currently includes:
- `br/public:avm/res/container-service/managed-cluster:0.12.0`
- `br/public:avm/res/network/virtual-network:0.7.2`
- `br/public:avm/res/operational-insights/workspace:0.15.0`

AKS is configured with the AVM `fluxExtension` enabled (`flux-system` release namespace) to support Flux GitOps extension deployment.

Parameter strategy:
- One shared parameter file: `templates/aks/main.bicepparam`
- `main.bicepparam` uses `#{{ variableName }}` placeholders for all parameter values
- Environment-specific values are injected at deploy time from `pipelines/variables/dev.yml` and `pipelines/variables/prd.yml` via qetza ReplaceTokens initialization in the deploy stage
- Complex values (arrays/objects/integers) are passed as strings and converted inside Bicep using `json()`/`int()` helper variables

> Review and update module versions regularly after validation.

## Required Azure DevOps Setup

1. Create an Azure Resource Manager service connection with least privilege.
2. Configure pipeline variables or variable groups:
   - `azureServiceConnection`
   - environment-specific values are provided in `pipelines/variables/dev.yml` and `pipelines/variables/prd.yml`
3. Configure environment approvals/checks for deployment environments.

## Security Notes

- Never commit credentials or secrets.
- Use Azure DevOps variable groups/Key Vault-backed secrets.
- Prefer private networking and production-hardening settings for non-dev environments.
