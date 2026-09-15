# 敲敲木鱼

HarmonyOS NEXT 原生单机电子木鱼：敲一下、计一次，全部功能离线运行；不申请网络权限，无登录、广告、支付与云同步，敲击记录只留在本机。

## 技术栈

- HarmonyOS NEXT，兼容与目标 SDK `6.0.2(22)`，本地构建使用 `6.1.1(24)` 工具链与 hvigor 6.24.3
- Stage 模型，ArkTS / ArkUI 声明式 UI，`entry` 单 HAP 模块
- 设备类型：phone、tablet、2in1（同一份代码按 600vp / 1024vp 断点限宽重排）
- 无第三方依赖，仅本地 OHPM 依赖（测试用 `@ohos/hypium`）
- 本地持久化：`@kit.ArkData` Preferences，设置与每日统计各以 JSON 字符串保存

## 功能特性

**敲击与反馈**

- 木鱼主体与木槌分层：手动和自动敲击共用同一 `hitSequence`，驱动木槌落下、木鱼回弹、涟漪波纹与浮字
- 三档互斥敲击模式：自由、目标、自动；自动档再次点击即关闭，切换模式立即停止定时器
- 目标模式显示进度条，可切换推荐目标（默认 108），达成后显示完成反馈并拦截额外计数
- 自动模式支持暂停 / 继续，显示本次已敲次数
- 反馈开关集中分组：音效开关、振动反馈、浮动文字、音量滑杆、音色选择与自定义敲击文字

**音色与外观**

- 低沉 / 清脆 / 柔和三种本地音色，SoundPool 试听，音量 0–100% 实时可调
- 三种主题：跟随系统、浅色、深色；系统栏颜色随页面与主题统一
- 视口小于 600vp 单列铺满，600vp 以上限宽 920 / 1180 并加卡片阴影

**本地统计**

- 日、周、月、年四套统计口径，均从本地每日记录实时计算
- 累计敲击、手动、自动、连续天数、最大单日指标与柱状趋势图
- 连续天数口径：当天有记录从当天回溯，当天未敲则保留截至昨天的连续记录
- 清除所有数据需二次确认，确认后只清记录、保留当前设置

**说明与合规**

- 设置页内置隐私政策页：数据存储、权限说明、第三方服务、儿童隐私分节说明
- 应用内版本信息统一取自 `AppVersion.version`，与 `AppScope/app.json5` 的 `1.0.0` 对齐

## 截图

> 以下为开发阶段在手机模拟器上的实际运行截图，仅用于状态说明；每张图都已签入仓库。

| 说明 | 截图 |
| --- | --- |
| 首页：木鱼、今日敲击与累计指标 | ![首页](docs/qa/screenshots/2026-07-30-phone-first-launch.jpeg) |
| 统计：周期切换与趋势 | ![统计](docs/qa/screenshots/2026-07-30-phone-stats.jpeg) |
| 设置：敲击反馈分组 | ![设置](docs/qa/screenshots/2026-07-30-feedback-settings-light.jpeg) |
| 深色主题首页 | ![深色首页](docs/qa/screenshots/2026-07-30-feedback-home-dark.jpeg) |
| 音色选择面板 | ![音色](docs/qa/screenshots/2026-07-30-feedback-sound-picker.jpeg) |

完整交互与构建证据见 `docs/qa/`。

## 目录结构

```
AppScope/                     应用级配置与应用名
entry/src/main/ets/
  pages/                      Index（导航与编排）、HomePage、StatsPage、SettingsPage、PrivacyPage
  components/                 WoodenFishView、BottomNavBar、StatsBarChart
  stores/                     AppRuntime、AppStore 应用级状态
  repositories/               SettingsRepository、StatsRepository 持久化
  data/                       PreferencesStore、LocalStoreAdapter、JsonCodec
  services/                   SessionService、AudioService、VibrationService、
                              StatsPeriodService、WindowChromeService、InitializationSlot
  models/                     AppModels、Enums、SystemBarModels
  constants/                  DesignTokens、UserModeConfigs、AppVersion
  utils/                      ThemeResolver、SystemBarStyleResolver、DateUtil、TextValidator
entry/src/main/resources/     string / color 资源、主题色板、导航与木鱼图片、三份 wav 音效
entry/src/ohosTest/ets/test/  Hypium 用例（模型、数据与会话、统计周期、系统栏）
docs/                         design / design-qa / changes 与 docs/qa 证据
scripts/                      构建脚本与静态门禁
```

## 构建与运行

1. 安装 DevEco Studio（自带 HarmonyOS SDK 与 hvigor），并确认 `sdk` 目录可被脚本路径 `C:\Program Files\Huawei\DevEco Studio\sdk` 找到
2. 运行时无第三方依赖，`vendor/hypium` 已是本地依赖，无需联网拉包
3. 用 DevEco Studio 打开工程目录，选择 `entry` 模块的 `default` 产品，`debug` 或 `release` 模式直接运行
4. 或在项目根目录执行脚本：

```powershell
# 静态门禁（必需文件、名称、权限与资源一致性）
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
# debug 主 HAP
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
# debug 测试 HAP
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
# release 主 HAP
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode release
```

构建产物位于 `entry/build/`，脚本会打印 HAP 路径与字节数。`check-standard.ps1` 及其子检查全部在仓库内自包含运行，只需 PowerShell，不依赖外部工具或网络；在 DevEco Studio 中运行测试需另行配置签名，仓库内不包含任何签名凭据。

## 隐私说明

- `entry/src/main/module.json5` 只申请一项权限：`ohos.permission.VIBRATE`，用途为敲击时的触觉反馈
- 不申请网络权限，也不申请定位、存储、相机等权限；没有联网能力，因此不存在数据上传路径
- 不接入广告 SDK、WebView、登录、排行、支付或云同步
- 敲击记录、设置偏好和统计数据只以 Preferences 形式保存在本机，卸载应用即随之删除
- 隐私政策全文随应用提供（设置页 → 隐私政策）

## 许可

代码为个人作品，仓库未附开源许可文件，默认保留全部权利，请勿直接商用或二次分发。三份敲击音效与图片资源为项目自有素材。