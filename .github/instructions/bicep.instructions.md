---
name: Bicep and AVM standards
description: Rules for Bicep, AVM modules, and parameter files
applyTo: "templates/**/*.bicep,templates/**/*.bicepparam,bicepconfig.json"
---

# Bicep instructions

- Prefer AVM modules from br/public:avm/... where available.
- Pin AVM module versions explicitly.
- Use clear parameter descriptions and safe defaults for local execution.
- Keep templates idempotent and environment-agnostic.
- Emit explicit outputs used by pipelines.
- Never store secrets in source-controlled bicepparam files.
- In tokenized `.bicepparam` files, keep all placeholder-substituted values as strings.
- Do not apply `int()`/`json()` directly to placeholder tokens in `.bicepparam` files.
- In `.bicep`, declare matching string parameters and create derived variables that apply conversions (for example `int(systemNodeCount)` or `json(tags)`) before resource/module usage.
