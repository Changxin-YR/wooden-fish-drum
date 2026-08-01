# 静心木鱼

静心木鱼是一款使用 ArkTS 与 ArkUI 开发的 HarmonyOS NEXT 单机应用。应用不申请网络权限，不包含登录、广告、支付或云同步。

## 技术基线

- HarmonyOS 6.0.2 API 22
- Stage 模型
- ArkTS / ArkUI
- phone、tablet、2in1
- Preferences 本地持久化

## 功能

- 统一普通用户体验；旧版本三种用户设置会安全迁移，并保留主题、音色和自定义文字。
- 自由、目标和自动三种互斥会话模式；再次点击自动可关闭，切换其他档位会立即停止自动计数。
- 木鱼主体与木槌分层，手动和自动敲击共用木槌落下、木鱼回弹、波纹和浮字反馈。
- 目标模式显示进度，达到 108 次后展示完成反馈并阻止额外计数。
- 日、周、月、年四套真实本地统计，以及累计、手动、自动、连续天数和最大单日指标。
- 低沉、清脆、柔和三种可见音色选择，支持音量、振动、浮字和本地试听。
- 跟随系统、浅色、深色三种完整主题，以及二次确认清除统计。
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

静心木鱼 V2.1 的三工具练习、真实记录、设置和本地合规页面已完成。项目标准门禁、debug/release/ohosTest 构建和 API 22 phone 设备 Hypium 54/54 均通过；phone 模拟器已完成深浅主题、练习、记录、设置、二级合规页面、弹层校验和清除确认交互验证。应用仅申请振动权限，无网络权限、广告 SDK、广告位、登录、支付或云同步。

当前 release 产物仍为 unsigned HAP；正式上架还需发布主体提供真实签名身份、备案信息、AppGallery 隐私政策公网 URL 和素材授权证明。tablet、2in1 运行态视觉验收仍为 `blocked`，不能由 phone 结果替代。完整清单见 `docs/qa/2026-07-31-release-readiness.md`。
