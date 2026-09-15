[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$componentPath = Join-Path $projectRoot 'entry\src\main\ets\components\WoodenFishView.ets'
$componentContent = Get-Content -Raw -Encoding UTF8 $componentPath

$requiredSnippets = @(
  "Image(`$r('app.media.muyu_mallet'))",
  '.width(190)',
  '.height(66)',
  "centerX: '90%'",
  '@State contactShadowOpacity: number = 0;',
  'private animationGeneration: number = 0;',
  'duration: 110',
  'duration: 55, curve: Curve.EaseInOut',
  'duration: 125, curve: Curve.EaseOut',
  'duration: 170, curve: Curve.EaseOut',
  'if (generation !== this.animationGeneration)',
  '}, 110);',
  '}, 165);',
  '}, 290);',
  'private malletPositionY(): number {',
  '@State viewWidth: number = 390;',
  'return this.dark ? -35 : (this.viewWidth >= 600 ? 8 : 38);',
  'this.viewWidth = Number(newValue.width);',
  'private contactShadowPositionY(): number {',
  'return this.dark ? 17 : (this.viewWidth >= 600 ? 45 : 78);',
  'private contactMalletAngle(): number {',
  'return this.viewWidth >= 600 ? 1 : -2;',
  'private contactMalletOffsetY(): number {',
  'return this.viewWidth >= 600 ? 0 : 5;',
  'this.malletAngle = this.contactMalletAngle();',
  'this.malletOffsetX = -4;',
  'this.malletOffsetY = this.contactMalletOffsetY();',
  'this.contactShadowOpacity = 0.42;',
  '.objectFit(ImageFit.Contain)',
  'Stack({ alignContent: Alignment.TopStart })',
  ".position({ x: 16, y: 8 })",
  'this.fishScale = 1;',
  'this.contactShadowOpacity = 0;'
)

foreach ($snippet in $requiredSnippets) {
  if (-not $componentContent.Contains($snippet)) {
    throw "Mallet layout check failed: missing required snippet '$snippet'."
  }
}

$geometricHeadText = '.backgroundColor(''#9C653B'')'
if ($componentContent.Contains($geometricHeadText)) {
  throw 'Mallet layout check failed: geometric mallet head is still present.'
}

$mediaPath = Join-Path $projectRoot 'entry\src\main\resources\base\media\muyu_mallet.png'
if (-not (Test-Path -LiteralPath $mediaPath -PathType Leaf)) {
  throw "Mallet layout check failed: missing media resource '$mediaPath'."
}

Add-Type -AssemblyName System.Drawing
$bitmap = [System.Drawing.Bitmap]::new($mediaPath)
try {
  if ($bitmap.Width -ne 857 -or $bitmap.Height -ne 189) {
    throw "Mallet layout check failed: expected 857x189 PNG, found $($bitmap.Width)x$($bitmap.Height)."
  }
  $corners = @(
    $bitmap.GetPixel(0, 0).A,
    $bitmap.GetPixel($bitmap.Width - 1, 0).A,
    $bitmap.GetPixel(0, $bitmap.Height - 1).A,
    $bitmap.GetPixel($bitmap.Width - 1, $bitmap.Height - 1).A
  )
  if (($corners | Where-Object { $_ -ne 0 }).Count -gt 0) {
    throw 'Mallet layout check failed: PNG corners must be fully transparent.'
  }
} finally {
  $bitmap.Dispose()
}

Write-Host 'Mallet layout check passed.' -ForegroundColor Green
