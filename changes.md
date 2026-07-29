# 变更记录

## 2026-07-30｜功德木鱼 V1.0

- 状态：`blocked`
- 用户请求：按批准的高保真设计快速准确完成完整 HarmonyOS V1.0。
- 项目类型：API 24 Stage 模型 ArkTS/ArkUI 单机应用。

### 已完成改动

- 建立 API 24 Stage 工程、本地 Hypium 依赖、静态门禁与 debug/release 构建脚本。
- 实现三种用户模式、首次启动选择、模式切换与设置持久化。
- 实现手动、目标、限时、自动会话状态机及后台停止。
- 实现每日统计、最近 7 日补零、累计/手动/自动/连续/最大单日派生与二次确认清除。
- 实现木鱼回弹、SoundPool 三音色、音量、振动与最多三条浮动文字。
- 实现模式选择、首页、统计、设置和底部导航，接入用户原始高保真素材。
- 从用户图标板原样裁切应用图标并配置到 AppScope 与 EntryAbility。
- 增加 Compact/Medium/Expanded 断点和宽屏限宽布局。

### 验证

- 项目标准检查：`passed`。
- 外部 HarmonyOS 标准检查：`passed`，仅有可选 `common/` 目录提示。
- 禁止能力扫描：`passed`，未发现网络、WebView 或 ArkTS `any`。
- debug 主 HAP：`passed`，1,541,941 bytes。
- release 主 HAP：`passed`，1,370,493 bytes。
- ohosTest HAP：`passed`，2,582,036 bytes。
- Hypium 运行态：`blocked`，当前 `hdc list targets` 为 `[Empty]`。
- 设备与交互：`blocked`，当前无 phone/tablet/2in1 目标。
- 证据索引：`docs/qa/2026-07-30-build.md`、`docs/qa/2026-07-30-interaction.md`、`docs/ui/asset-manifest.md`。

### 遗留风险

- 未配置签名身份，当前产物为 unsigned HAP；保持了用户要求的不擅自修改签名身份。
- phone、tablet、2in1 的运行截图、音频听感、振动和交互仍需设备证据，不以编译结果替代。
