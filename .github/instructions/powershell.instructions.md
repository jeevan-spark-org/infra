---
name: PowerShell standards
description: Rules for CI-safe PowerShell automation scripts
applyTo: "scripts/**/*.ps1"
---

# PowerShell instructions

- Use Set-StrictMode -Version Latest.
- Set $ErrorActionPreference = 'Stop'.
- Validate parameters and file paths before running Azure commands.
- Keep scripts non-interactive and pipeline-safe.
- Fail fast with non-zero exit behavior on errors.
- Log clear, concise operational messages.
