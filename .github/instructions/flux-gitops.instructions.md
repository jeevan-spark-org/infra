---
name: Flux GitOps standards
description: Rules for enabling and maintaining Flux GitOps extension for AKS
applyTo: "templates/**/*.bicep,templates/**/*.bicepparam,pipelines/**/*.yml"
---

# Flux GitOps instructions

- Keep AKS Flux extension enabled for all target environments unless explicitly disabled by user request.
- Prefer AVM-managed Flux extension configuration via the AKS managed-cluster module.
- Keep environment-specific settings in parameter and variable files, not hardcoded in pipeline logic.
- Validate Flux-related infrastructure changes through Validate and WhatIf stages before deploy.
- Do not store Git credentials, PATs, or private keys in source control.
