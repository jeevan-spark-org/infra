---
name: Azure Pipelines standards
description: Rules for pipeline entrypoints, templates, and deployment safety
applyTo: "azure-pipelines.yml,pipelines/**/*.yml"
---

# Azure Pipelines instructions

- Keep parent pipeline definitions in pipelines.
- Keep root azure-pipelines.yml as a thin extends wrapper.
- Split delivery into Validate, WhatIf, and Deploy stages.
- Reuse stage and step templates.
- Parameterize service connections, locations, and environment names.
- Model deployable resources as an object array (`deploymentTemplates`) with `name`, `templateFile`, and `parameterFile`, and iterate over it in Validate/WhatIf/Deploy.
- Keep reusable step templates generic for any Bicep template (avoid resource-specific naming in shared pipeline steps).
- Keep environment names lowercase and load environment variable files using lowercase conventions (for example `variables/dev.yml`, `variables/prd.yml`).
- Ensure every pipeline YAML file is properly formatted with consistent indentation before finalizing changes.
- Use branch and stage conditions to protect deployment stages.
- Never place secrets directly in YAML.
