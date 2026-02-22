# Repository custom instructions for Copilot

This repository provisions Azure infrastructure (AKS) by using Bicep and Azure Verified Modules (AVM), orchestrated by Azure Pipelines.

## Scope and structure
- Keep parent pipeline definitions under pipelines.
- Keep deployable Bicep and bicepparam files under templates.
- Keep reusable stage templates, step templates, variable templates, and automation scripts in `infra-pipeline-common`.
- Keep root azure-pipelines.yml as a lightweight wrapper that extends the parent pipeline in pipelines.
- Keep pipeline step/template names generic (avoid resource-specific names like AKS in reusable files).

## Implementation rules
- Prefer AVM modules from br/public:avm/... when available.
- Pin module versions explicitly and update only after validation.
- Keep infrastructure deployments idempotent and safe to rerun.
- Do not hardcode credentials, secrets, tenant IDs, subscription IDs, or principal secrets.
- Use secure pipeline variables, variable groups, or Key Vault references for sensitive values.

## Bicep and IaC quality
- For tokenized bicepparam files, treat incoming placeholder values as strings and convert in Bicep using helper variables (for example `int()` and `json()`).
- Keep bicepparam files placeholder-only and free of inline conversion functions.
- Validate and preview changes before deployment (build, validate, what-if).
- After running local Bicep builds, remove generated compiled JSON artifacts (for example `templates/**/<name>.json`) before finishing the task.
- Keep outputs explicit for downstream pipeline use.

## Pipeline quality
- Maintain stage separation: Validate, WhatIf, Deploy.
- Reuse stage and step templates instead of duplicating YAML.
- Keep deployment inputs generic by passing an array of deployment templates (`name`, `templateFile`, `parameterFile`) and iterating in Validate/WhatIf/Deploy.
- Keep service connections and environment names configurable through parameters or variables.
- Keep environment names lowercase and align environment variable file names to lowercase in `infra-pipeline-common` (for example `pipelines/variables/dev.yml`).

## Change safety
- Keep edits focused and minimal.
- When changing behavior, update related templates and docs in the same change.
