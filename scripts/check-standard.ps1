[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$problems = [System.Collections.Generic.List[string]]::new()

$requiredFiles = @(
  'README.md',
  'AGENTS.md',
  'tasks.md',
  'changes.md',
  'design.md',
  'design-qa.md',
  'docs\qa\README.md',
  'build-profile.json5',
  'oh-package.json5',
  'package.json',
  'hvigorfile.ts',
  'hvigor\hvigor-config.json5',
  'AppScope\app.json5',
  'AppScope\resources\base\media\app_icon.png',
  'entry\build-profile.json5',
  'entry\oh-package.json5',
  'entry\hvigorfile.ts',
  'entry\src\main\module.json5',
  'entry\src\main\ets\entryability\EntryAbility.ets',
  'entry\src\main\ets\pages\Index.ets',
  'entry\src\main\ets\pages\ModeSelectPage.ets',
  'entry\src\main\ets\pages\HomePage.ets',
  'entry\src\main\ets\pages\StatsPage.ets',
  'entry\src\main\ets\pages\SettingsPage.ets',
  'entry\src\main\ets\components\TodaySummaryCard.ets',
  'entry\src\main\ets\components\BeadsView.ets',
  'entry\src\main\ets\components\IncenseView.ets',
  'entry\src\main\ets\components\ToolSegmentedControl.ets',
  'entry\src\main\ets\components\PracticeControlDock.ets',
  'entry\src\main\ets\components\WoodenFishView.ets',
  'entry\src\main\ets\services\PracticeController.ets',
  'entry\src\main\ets\services\AudioService.ets',
  'entry\src\main\ets\services\VibrationService.ets',
  'entry\src\main\resources\base\media\app_icon.png',
  'entry\src\main\resources\base\media\muyu_brand.png',
  'entry\src\main\resources\base\media\muyu_body_dark.png',
  'entry\src\main\resources\base\media\muyu_body_light.png',
  'entry\src\main\resources\base\media\practice_wooden_fish.png',
  'entry\src\main\resources\base\media\practice_beads.png',
  'entry\src\main\resources\base\media\practice_incense.png',
  'entry\src\main\resources\rawfile\sounds\deep.wav',
  'entry\src\main\resources\rawfile\sounds\crisp.wav',
  'entry\src\main\resources\rawfile\sounds\soft.wav',
  'entry\src\main\resources\base\profile\main_pages.json',
  'entry\src\ohosTest\module.json5',
  'entry\src\ohosTest\ets\test\List.test.ets',
  'entry\src\ohosTest\ets\test\PracticeController.test.ets',
  'vendor\hypium\oh-package.json5'
)

foreach ($relativePath in $requiredFiles) {
  $fullPath = Join-Path $projectRoot $relativePath
  if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
    $problems.Add("Missing file: $relativePath")
    continue
  }
  if ((Get-Item -LiteralPath $fullPath).Length -eq 0) {
    $problems.Add("Empty file: $relativePath")
  }
}

function Read-JsonFile([string]$RelativePath) {
  $fullPath = Join-Path $projectRoot $RelativePath
  if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
    return $null
  }
  try {
    return Get-Content -Raw -Encoding UTF8 -LiteralPath $fullPath | ConvertFrom-Json
  }
  catch {
    $problems.Add("Invalid JSON in ${RelativePath}: $($_.Exception.Message)")
    return $null
  }
}

$app = Read-JsonFile 'AppScope\app.json5'
if ($null -ne $app -and $app.app.bundleName -ne 'com.max.muyu') {
  $problems.Add('AppScope/app.json5 must use bundle name com.max.muyu')
}

$rootProfile = Read-JsonFile 'build-profile.json5'
if ($null -ne $rootProfile) {
  $product = @($rootProfile.app.products) | Where-Object { $_.name -eq 'default' } | Select-Object -First 1
  if ($null -eq $product) {
    $problems.Add('build-profile.json5 is missing the default product')
  }
  elseif ($product.compatibleSdkVersion -ne '6.1.1(24)' -or $product.targetSdkVersion -ne '6.1.1(24)') {
    $problems.Add('The default product must target HarmonyOS 6.1.1(24)')
  }
}

$package = Read-JsonFile 'package.json'
if ($null -ne $package) {
  foreach ($dependency in '@ohos/hvigor', '@ohos/hvigor-ohos-plugin') {
    if ($package.dependencies.$dependency -ne '6.24.3') {
      $problems.Add("package.json must pin $dependency to 6.24.3")
    }
  }
}

$module = Read-JsonFile 'entry\src\main\module.json5'
if ($null -ne $module) {
  $deviceTypes = @($module.module.deviceTypes)
  if ($deviceTypes.Count -ne 3 -or
    'phone' -notin $deviceTypes -or
    'tablet' -notin $deviceTypes -or
    '2in1' -notin $deviceTypes) {
    $problems.Add('entry module must declare only phone, tablet, and 2in1 device types')
  }

  $permissions = @($module.module.requestPermissions)
  if ($permissions.Count -ne 1 -or $permissions[0].name -ne 'ohos.permission.VIBRATE') {
    $problems.Add('entry module must request only ohos.permission.VIBRATE')
  }
}

$pages = Read-JsonFile 'entry\src\main\resources\base\profile\main_pages.json'
if ($null -ne $pages -and (@($pages.src).Count -ne 1 -or $pages.src[0] -ne 'pages/Index')) {
  $problems.Add('main_pages.json must declare pages/Index as its only page')
}

$testListPath = Join-Path $projectRoot 'entry\src\ohosTest\ets\test\List.test.ets'
if ($problems.Count -gt 0) {
  Write-Host 'Standard project check failed:' -ForegroundColor Red
  foreach ($problem in $problems) {
    Write-Host " - $problem" -ForegroundColor Red
  }
  exit 1
}

Write-Host 'Standard project check passed.' -ForegroundColor Green
Write-Host "Project: $projectRoot"
