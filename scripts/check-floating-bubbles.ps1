[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$componentPath = Join-Path $projectRoot 'entry\src\main\ets\components\WoodenFishView.ets'
$source = Get-Content -Raw -Encoding UTF8 -LiteralPath $componentPath

$requiredFragments = @(
  'private floatingTextDistanceFromNewest(index: number): number {',
  'private floatingTextOffsetY(index: number): number {',
  'return -48 * this.floatingTextDistanceFromNewest(index);',
  'private floatingTextOpacity(index: number): number {',
  'return 0.76;',
  'return 0.52;',
  'ForEach(this.floatingTexts, (item: string, index: number) => {',
  '.opacity(this.floatingTextOpacity(index))',
  '.translate({ y: this.floatingTextOffsetY(index) })',
  '.height(44)',
  '.position({ x: 0, y: 8 })'
)

foreach ($fragment in $requiredFragments) {
  if (-not $source.Contains($fragment)) {
    throw "Floating bubble layout check failed: missing '$fragment'."
  }
}

$threeItemLimits = ([regex]::Matches($source, [regex]::Escape('next.length - 3'))).Count
$cleanupTimers = ([regex]::Matches($source, [regex]::Escape('}, 760);'))).Count
if ($threeItemLimits -ne 2) {
  throw "Floating bubble layout check failed: expected two three-item limits, found $threeItemLimits."
}
if ($cleanupTimers -ne 2) {
  throw "Floating bubble layout check failed: expected two 760ms cleanup timers, found $cleanupTimers."
}

Write-Host 'Floating bubble layout check passed.' -ForegroundColor Green
