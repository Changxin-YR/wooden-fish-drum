# 功德木鱼

功德木鱼是一款使用 ArkTS 与 ArkUI 开发的 HarmonyOS NEXT 单机应用。应用不申请网络权限，不包含登录、广告、支付或云同步。

## 技术基线

- HarmonyOS 6.1.1 API 24
- Stage 模型
- ArkTS / ArkUI
- phone、tablet、2in1
- Preferences 本地持久化

## 功能

- 首次启动选择程序员、僧侣或普通用户模式，之后可在设置中切换。
- 手动敲击、目标、限时和自动四种会话模式。
- 木鱼回弹、三种音色、音量、振动与最多三条浮动文字反馈。
- 今日、累计、手动、自动、连续天数、最大单日和最近 7 日趋势统计。
- 自定义敲击文字、深浅色、反馈开关和二次确认清除统计。
- Compact、Medium、Expanded 三档限宽响应式布局。

## 目录

- `entry/src/main/ets/pages/`：页面和应用入口编排。
- `entry/src/main/ets/components/`：木鱼、模式卡、统计图与底部导航。
- `entry/src/main/ets/stores/`：应用级状态和运行时依赖。
- `entry/src/main/ets/repositories/`：设置与每日统计持久化。
- `entry/src/main/ets/services/`：会话、音频和振动能力。
- `entry/src/main/ets/models/`、`constants/`、`utils/`：强类型模型、配置和纯逻辑。

## 构建

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug -Target ohosTest
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode release
```

构建产物位于 `entry/build/default/outputs/default/` 下。设备测试与交互证据记录在 `docs/qa/`。

## 当前状态

V1.0 功能代码、构建门禁和 phone 模拟器核心交互验收已完成。Hypium 10/10 通过，首启、敲击、统计、设置与强停重启持久化均有真实运行截图。当前缺少 tablet、2in1 目标，其实际设备视觉验收仍明确标记为 `blocked`。证据记录在 `docs/qa/`。
