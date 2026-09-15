[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$indexPath = Join-Path $projectRoot 'entry\src\main\ets\pages\Index.ets'
$abilityPath = Join-Path $projectRoot 'entry\src\main\ets\entryability\EntryAbility.ets'
$servicePath = Join-Path $projectRoot 'entry\src\main\ets\services\WindowChromeService.ets'
$index = Get-Content -Raw -Encoding UTF8 -LiteralPath $indexPath
$ability = Get-Content -Raw -Encoding UTF8 -LiteralPath $abilityPath
$service = Get-Content -Raw -Encoding UTF8 -LiteralPath $servicePath
$problems = [System.Collections.Generic.List[string]]::new()

if ($index -notmatch "@Watch\('onSystemDarkChange'\)") {
  $problems.Add('Index must watch systemDark changes.')
}
if ($index -notmatch 'private syncSystemBars\(\): void') {
  $problems.Add('Index must centralize system bar synchronization.')
}
if ([regex]::Matches($index, 'this\.syncSystemBars\(\);').Count -lt 3) {
  $problems.Add('Index must synchronize after settings, tab, and system theme changes.')
}
if ($ability -notmatch 'windowChromeService\.refresh\(\)') {
  $problems.Add('EntryAbility must reapply system bars after content loading.')
}
if ($service -notmatch 'setWindowLayoutFullScreen\(false\)') {
  $problems.Add('WindowChromeService must keep content outside the system bars.')
}

if ($problems.Count -gt 0) {
  Write-Host 'System bar check failed:' -ForegroundColor Red
  foreach ($problem in $problems) {
    Write-Host " - $problem"
  }
  exit 1
}

Write-Host 'System bar check passed.' -ForegroundColor Green
