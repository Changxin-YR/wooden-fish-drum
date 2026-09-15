[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$indexPath = Join-Path $projectRoot 'entry\src\main\ets\pages\Index.ets'
$modulePath = Join-Path $projectRoot 'entry\src\main\module.json5'
$indexContent = Get-Content -Raw -Encoding UTF8 -LiteralPath $indexPath
$moduleContent = Get-Content -Raw -Encoding UTF8 -LiteralPath $modulePath
$problems = [System.Collections.Generic.List[string]]::new()

foreach ($requiredStartWindowSetting in @(
  '"startWindowIcon": "$media:app_icon"',
  '"startWindowBackground": "$color:start_window_background"'
)) {
  if (-not $moduleContent.Contains($requiredStartWindowSetting)) {
    $problems.Add("EntryAbility is missing required system start-window setting: $requiredStartWindowSetting")
  }
}

if ([regex]::IsMatch($indexContent, 'app\.media\.app_icon')) {
  $problems.Add('Index must not draw the app icon after the system start window.')
}

if ([regex]::IsMatch($indexContent, 'await\s+audioService\.initialize\s*\(')) {
  $problems.Add('Audio initialization must not block the first application frame.')
}

$readyIndex = $indexContent.LastIndexOf('this.ready = true;', [StringComparison]::Ordinal)
$audioIndex = $indexContent.IndexOf('audioService.initialize(hostContext);', [StringComparison]::Ordinal)
if ($readyIndex -lt 0 -or $audioIndex -lt 0 -or $readyIndex -gt $audioIndex) {
  $problems.Add('The first application frame must be enabled before audio initialization starts.')
}

if ($problems.Count -gt 0) {
  Write-Host 'Startup flow check failed:' -ForegroundColor Red
  foreach ($problem in $problems) {
    Write-Host " - $problem" -ForegroundColor Red
  }
  exit 1
}

Write-Host 'Startup flow check passed.' -ForegroundColor Green
