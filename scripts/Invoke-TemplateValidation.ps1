[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Location,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TemplateFile,

    [Parameter()]
    [string]$ParametersFile,

    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-PathExists {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Description
    )

    if (-not (Test-Path -Path $Path)) {
        throw "$Description not found at path: $Path"
    }
}

Write-Host "Verifying template inputs..."
Assert-PathExists -Path $TemplateFile -Description 'Bicep template'

if ($ParametersFile) {
    Assert-PathExists -Path $ParametersFile -Description 'Bicep parameters file'
}

Write-Host "Building Bicep template: $TemplateFile"
az bicep build --file $TemplateFile | Out-Null

if ($WhatIf.IsPresent) {
    Write-Host "Running What-If for deployment: $DeploymentName"
    $commandArgs = @(
        'deployment', 'sub', 'what-if',
        '--name', $DeploymentName,
        '--location', $Location,
        '--template-file', $TemplateFile
    )

    if ($ParametersFile) {
        $commandArgs += @('--parameters', $ParametersFile)
    }

    az @commandArgs
}
else {
    Write-Host "Running Validate for deployment: $DeploymentName"
    $commandArgs = @(
        'deployment', 'sub', 'validate',
        '--name', $DeploymentName,
        '--location', $Location,
        '--template-file', $TemplateFile
    )

    if ($ParametersFile) {
        $commandArgs += @('--parameters', $ParametersFile)
    }

    az @commandArgs | Out-Null
}
