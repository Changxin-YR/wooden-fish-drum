$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$expectedName = [string]([char]0x6572) + [char]0x6572 + [char]0x6728 + [char]0x9C7C
$legacyNames = @(
  [string]([char]0x4E00) + [char]0x6572 + [char]0x4E00 + [char]0x5FF5,
  [string]([char]0x9759) + [char]0x5FC3 + [char]0x6728 + [char]0x9C7C,
  [string]([char]0x529F) + [char]0x5FB7 + [char]0x6728 + [char]0x9C7C
)
$checks = @(
  'AppScope/resources/base/element/string.json',
  'package.json',
  'oh-package.json5',
  'entry/src/main/resources/base/element/string.json',
  'entry/oh-package.json5',
  'entry/src/main/ets/pages/SettingsPage.ets',
  'entry/src/main/ets/pages/PrivacyPage.ets',
  'README.md',
  'design.md'
)

$failed = $false
foreach ($relativePath in $checks) {
  $path = Join-Path $projectRoot $relativePath
  $content = Get-Content -LiteralPath $path -Encoding utf8 -Raw
  if (-not $content.Contains($expectedName)) {
    Write-Error "App name check failed: $relativePath does not contain the expected name." -ErrorAction Continue
    $failed = $true
  }
  foreach ($legacyName in $legacyNames) {
    if ($content.Contains($legacyName)) {
      Write-Error "App name check failed: $relativePath still contains a legacy name." -ErrorAction Continue
      $failed = $true
    }
  }
}

if ($failed) {
  exit 1
}

Write-Host "App name check passed: all current user-facing entries use the expected name."
