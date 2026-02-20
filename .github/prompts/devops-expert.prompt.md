---
name: devops-expert
description: Run infrastructure tasks with the devops-expert custom agent
agent: agent
---

Use the devops-expert custom agent for Azure infrastructure changes in this repository.

Task requirements:
- Use official Microsoft and GitHub documentation for platform behavior.
- Keep parent pipelines in pipelines and deployable Bicep in templates.
- Keep deployment flow as Validate -> WhatIf -> Deploy.
- Keep deployment logic generic by using a deployment template array (`name`, `templateFile`, `parameterFile`) and loop through entries in Validate/WhatIf/Deploy.
- Keep reusable pipeline step templates generic (avoid resource-specific naming in shared templates).
- Keep environment names lowercase and align variable template file names to lowercase.
- Prefer AVM modules with explicit version pins.
- For tokenized `.bicepparam` placeholders, pass values as strings and perform `int()`/`json()` conversion in `.bicep` helper variables.
- Do not commit secrets.
