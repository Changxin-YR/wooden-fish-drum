# 变更记录

## 2026-07-30｜功德木鱼 V1.0

- 状态：`done`
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
- 修复快速连续敲击时 Preferences 写入乱序导致的计数丢失，并增加乱序写入回归用例。
- 修复 ArkUI Builder 中汇总值未实时刷新的状态观察问题。
- 从用户 UI 图标板原样裁切首页、统计、设置图标，替换可能被系统渲染为彩色 Emoji 的字符。

### 验证

- 项目标准检查：`passed`。
- 外部 HarmonyOS 标准检查：`passed`，仅有可选 `common/` 目录提示。
- 禁止能力扫描：`passed`，未发现网络、WebView 或 ArkTS `any`。
- debug 主 HAP：`passed`，1,667,250 bytes。
- release 主 HAP：`passed`，1,493,515 bytes。
- ohosTest HAP：`passed`，2,588,515 bytes。
- Hypium 运行态：`passed`，10/10，Failure 0，Error 0。
- phone 设备与交互：`passed`，目标 `127.0.0.1:5555`，已归档 8 张运行截图。
- tablet、2in1 设备交互：`blocked`，当前没有对应目标；响应式代码与构建门禁已通过。
- 证据索引：`docs/qa/2026-07-30-build.md`、`docs/qa/2026-07-30-interaction.md`、`docs/ui/asset-manifest.md`。

### 遗留风险

- 未配置签名身份，当前产物为 unsigned HAP；保持了用户要求的不擅自修改签名身份。
- 音频听感和真实振感无法由模拟器截图客观证明；服务调用、开关和降级路径已通过构建与代码门禁。
- tablet、2in1 的实际运行截图仍需对应设备，不以 phone 结果替代。
