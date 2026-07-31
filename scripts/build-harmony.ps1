[CmdletBinding()]
param(
  [ValidateSet('debug', 'release')]
  [string]$BuildMode = 'debug',
  [ValidateSet('default', 'ohosTest')]
  [string]$Target = 'default',
  [string]$SdkRoot = 'C:\Program Files\Huawei\DevEco Studio\sdk'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$devEcoRoot = Split-Path -Parent $SdkRoot
$hvigor = Join-Path $devEcoRoot 'tools\hvigor\bin\hvigorw.bat'
$node = Join-Path $devEcoRoot 'tools\node\node.exe'
$ohpm = Join-Path $devEcoRoot 'tools\ohpm\bin\pm-cli.js'
$vendorHypium = Join-Path $projectRoot 'vendor\hypium\oh-package.json5'

foreach ($requiredPath in $SdkRoot, $hvigor, $node, $ohpm, $vendorHypium) {
  if (-not (Test-Path -LiteralPath $requiredPath)) {
    throw "Required local build resource was not found: $requiredPath"
  }
}

$rootManifestPath = Join-Path $projectRoot 'oh-package.json5'
$rootManifest = Get-Content -Raw -Encoding UTF8 -LiteralPath $rootManifestPath | ConvertFrom-Json
$ohpmDependencies = @($rootManifest.dependencies.psobject.Properties) +
  @($rootManifest.devDependencies.psobject.Properties) +
  @($rootManifest.dynamicDependencies.psobject.Properties) |
  Where-Object { $null -ne $_ }
foreach ($dependency in $ohpmDependencies) {
  if (-not ([string]$dependency.Value).StartsWith('file:', [StringComparison]::OrdinalIgnoreCase)) {
    throw "Only local OHPM dependencies are allowed by this build script: $($dependency.Name)"
  }
}

$env:DEVECO_SDK_HOME = $SdkRoot
$env:HOS_SDK_HOME = $SdkRoot
$env:OHOS_SDK_HOME = $SdkRoot
$env:NODE_HOME = Split-Path -Parent $node

Push-Location $projectRoot
try {
  Write-Host 'Installing project-local OHPM dependencies.'
  & $node $ohpm install --all --log_level warn
  if ($LASTEXITCODE -ne 0) {
    throw "Local OHPM install failed with exit code $LASTEXITCODE"
  }

  & $hvigor --mode module -p product=default -p "buildMode=$BuildMode" -p "module=entry@$Target" assembleHap --no-daemon
  if ($LASTEXITCODE -ne 0) {
    throw "HarmonyOS build failed with exit code $LASTEXITCODE"
  }

  $buildRoot = Join-Path $projectRoot "entry\build\default\outputs\$Target"
  $artifact = Get-ChildItem -LiteralPath $buildRoot -File -Filter '*.hap' |
    Sort-Object LastWriteTimeUtc -Descending |
    Select-Object -First 1
  if ($null -eq $artifact -or $artifact.Length -eq 0) {
    throw "Build succeeded, but no non-empty HAP was found below: $buildRoot"
  }

  Write-Host 'HarmonyOS build passed.' -ForegroundColor Green
  Write-Host "Target: $Target"
  Write-Host "Build mode: $BuildMode"
  Write-Host "Artifact: $($artifact.FullName)"
  Write-Host "Size: $($artifact.Length) bytes"
}
finally {
  Pop-Location
}
