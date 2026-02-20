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

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ParametersFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -Path $TemplateFile)) {
    throw "Bicep template not found: $TemplateFile"
}

if (-not (Test-Path -Path $ParametersFile)) {
    throw "Bicep parameters file not found: $ParametersFile"
}

Write-Host "Creating deployment: $DeploymentName"
$commandArgs = @(
    'deployment', 'sub', 'create',
    '--name', $DeploymentName,
    '--location', $Location,
    '--template-file', $TemplateFile,
    '--parameters', $ParametersFile
)

az @commandArgs
