[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$homePagePath = Join-Path $projectRoot 'entry\src\main\ets\pages\HomePage.ets'
$homePageContent = Get-Content -Raw -Encoding UTF8 -LiteralPath $homePagePath
$problems = [System.Collections.Generic.List[string]]::new()

if ($homePageContent.Contains([char]::ConvertFromUtf32(0x23F8))) {
  $problems.Add('HomePage must not use the system-rendered pause Emoji.')
}

foreach ($requiredText in @(
  '@Builder',
  'PauseIcon()',
  'DesignTokens.wood',
  'DesignTokens.accentDark'
)) {
  if (-not $homePageContent.Contains($requiredText)) {
    $problems.Add("HomePage is missing required pause icon source: $requiredText")
  }
}

if ($problems.Count -gt 0) {
  Write-Host 'Pause icon check failed:' -ForegroundColor Red
  foreach ($problem in $problems) {
    Write-Host " - $problem" -ForegroundColor Red
  }
  exit 1
}

Write-Host 'Pause icon check passed.' -ForegroundColor Green
