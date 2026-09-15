# 变更记录

## 2026-08-03｜应用更名为敲敲木鱼

- 状态：`done`
- 用户确认使用更通俗直白的名称“敲敲木鱼”。

### 当前改动

- AppScope 桌面应用名、EntryAbility 标签、设置页“关于应用”和隐私页文案统一为“敲敲木鱼”。
- 根模块、Entry 模块、当前 README/设计目标及名称回归检查同步使用新名称。
- 桌面上架图标文件同步改名，保持包名 `com.max.muyu`、版本号和图标画面不变。

### 验证

- 名称回归检查先在旧名称下按预期失败，完成更名后通过。
- 项目标准门禁、外部 HarmonyOS 标准检查与 `git diff --check` 通过。
- debug 主 HAP、debug ohosTest HAP、release 主 HAP 均构建成功；phone 模拟器 Hypium 27/27 通过，最新 debug 应用已安装并启动。
- 桌面 PNG 为 216×216、91,693 bytes；与包内 360×360 图标等比例缩放后逐像素一致。
- 详细证据见 `docs/qa/2026-08-03-app-name.md`。

## 2026-08-03｜应用更名为一敲一念

- 状态：`done`
- 用户请求：“静心木鱼”已被注册，改用更有辨识度的新名称。

### 已完成改动

- AppScope 桌面应用名与 EntryAbility 标签统一为“一敲一念”。
- 新名称取“敲一下、收一念”之意；公开检索未发现明显同名应用，但最终可用性以应用市场后台校验为准。
- 设置页“关于应用”、隐私页标题与概述统一使用新名称。
- 根模块、Entry 模块说明以及当前 README/设计目标统一使用新名称。
- 保持包名 `com.max.muyu`、版本号、应用图标、数据键和既有功能不变。
- 新增 `scripts/check-app-name.ps1` 并接入项目标准门禁，防止当前用户可见入口回退到旧名称。

### 验证

- TDD 红灯：定向名称检查在旧名称下失败；补齐根模块检查时再次准确失败。
- 应用名称检查、项目标准检查、外部 HarmonyOS 标准检查与 `git diff --check`：`passed`。
- debug 主 HAP：`passed`，4,941,777 bytes。
- debug ohosTest HAP：`passed`，5,935,028 bytes。
- release 主 HAP：`passed`，4,698,102 bytes。
- phone 模拟器：最新 debug HAP 安装、启动成功；Hypium 27/27，Failure 0，Error 0。
- ohosTest 首次增量构建因失效的 Hvigor 模块缓存失败；执行官方 `hvigor clean` 后完整重建通过，未修改业务源码或依赖配置。

## 2026-08-03｜连续天数与会话快照修复

- 状态：`done`
- 用户请求：从测试报告中选择合理建议，修复当天首次敲击前连续天数误显示为 0，以及页面手工复制会话字段容易漏同步的问题。

### 已完成改动

- 连续天数在今天有记录时从今天倒推；今天尚无记录时从昨天倒推，保留截至昨天仍有效的连续记录，并继续在首个断档处停止。
- `SessionState.snapshot()` 集中创建完整、独立的会话状态副本，`Index` 不再逐字段维护复制清单。
- 新增今天未敲、今天已敲、历史断档和会话快照完整性/引用独立性回归测试。
- 保留自动模式再次点击关闭、自动模式忽略手动点击、目标模式和定时器生命周期等既定行为。

### 验证

- TDD 红灯：phone Hypium 26/27，`preservesStreakBeforeTodaysFirstHit` 明确报告期望 2、实际 0；快照方法实现前 ohosTest 编译明确报告 `snapshot` 不存在。
- 项目标准检查与 `git diff --check`：`passed`。
- debug 主 HAP：`passed`，4,905,682 bytes。
- debug ohosTest HAP：`passed`，5,895,582 bytes。
- release 主 HAP：`passed`，4,656,493 bytes。
- phone 模拟器 Hypium：`passed`，27/27，Failure 0，Error 0，`OHOS_REPORT_CODE: 0`；最新 debug 应用启动成功。
- 2in1 模拟器 Hypium：`passed`，27/27，Failure 0，Error 0，`OHOS_REPORT_CODE: 0`；最新 debug 应用启动成功。
- tablet：`blocked`，当前无可用目标。

详细证据见 `docs/qa/2026-08-03-streak-session-snapshot.md`。

## 2026-08-03｜系统栏沉浸式配色统一

- 状态：`done`
- 用户请求：在内容不侵入状态栏和导航栏的前提下，统一修正应用内所有页面的系统栏颜色断层。

### 已完成改动

- 新增纯逻辑系统栏样式解析器：浅色首页状态栏使用 `#FAF4EF`，浅色统计/设置/隐私页使用 `#F6F1E8`，深色状态栏使用 `#171513`。
- 系统导航栏与手势区延续应用底栏：浅色使用 `#FFFDF8`，深色使用 `#24211E`；窗口背景同步该表面色以兼容 API 24 手势导航模式。
- `WindowChromeService` 集中持有窗口能力，保持非全屏布局，在内容加载完成后重新应用系统栏样式，并对重复写入去重。
- `Index` 在设置快照更新、标签切换和系统主题变化时显式同步系统栏，覆盖首页、统计、设置和设置内隐私页。
- 新增 5 项系统栏 Hypium 回归用例和 `check-system-bars.ps1` 静态门禁。

### 验证

- 项目标准检查与 `git diff --check`：`passed`。
- debug 主 HAP：`passed`，4,901,851 bytes。
- debug ohosTest HAP：`passed`，5,887,225 bytes。
- release 主 HAP：`passed`，4,654,355 bytes。
- phone 模拟器 Hypium：`passed`，24/24，Failure 0，Error 0，`OHOS_REPORT_CODE: 0`。
- phone 浅色首页、深色首页、深/浅设置和隐私页：`passed`，上下系统栏连续且内容未进入系统安全区。
- 2in1 模拟器宽屏启动：`passed`，最新版应用窗口正常显示且内容未与桌面系统区域重叠。
- tablet：`blocked`，当前无可用目标。

详细证据见 `docs/qa/2026-08-03-system-bars.md`。

## 2026-08-03｜木槌造型与敲击动画优化

- 状态：`done`
- 用户请求：采用推荐的半写实弧击方案，并把木槌替换为参考图中的水滴形木槌。

### 已完成改动

- 从用户参考图提取独立透明木槌资源，保留水滴形槌头、收颈双环、长圆柄和真实木纹，不携带米白背景矩形。
- ArkUI 木槌改为绕手柄右端 90% 锚点旋转，敲击分为 110ms 落下、55ms 接触、125ms 回弹和 170ms 复位。
- 接触阶段增加木鱼轻压、冠部接触阴影和声波反馈，所有动画属性最终复位到固定值。
- 根据组件宽度和主题校准静止位置与落差，适配 phone 与 2in1 上 `ImageFit.Cover` 产生的不同裁切。
- 扩展 `scripts/check-mallet-layout.ps1`，锁定透明资源、稳定尺寸、锚点、响应式落点和四阶段时序。

### 验证

- 木槌定向检查、项目标准检查与 `git diff --check`：`passed`。
- debug 主 HAP：`passed`，4,904,772 bytes。
- debug ohosTest HAP：`passed`，5,887,225 bytes。
- release 主 HAP：`passed`，4,656,197 bytes。
- phone 模拟器 Hypium：`passed`，24/24，Failure 0，Error 0，`OHOS_REPORT_CODE: 0`。
- phone 真实运动帧与 2in1 静止位置：`passed`；详细证据见 `docs/qa/2026-08-03-mallet-motion.md`。
- tablet：`blocked`，当前没有可用目标。

## 2026-08-03｜冷启动图标闪现优化

- 状态：`done`
- 用户请求：解决进入应用时图标短暂闪现、木槌看起来像放大镜的问题。

### 已完成改动

- 保留 HarmonyOS `startWindowIcon` 和启动背景，系统启动窗口仍承担唯一的品牌启动展示。
- 移除 `Index` 在 `ready=false` 阶段重复绘制的应用图标、加载环和加载文字，ArkUI 接管时只显示与首页一致的背景。
- Preferences 与业务状态完成同步后立即显示首页，三段音频资源改为首屏状态切换后异步初始化。
- 音频资源使用带世代令牌的 `InitializationSlot` 管理；退后台或新初始化会使旧候选失效并释放，避免异步初始化恢复后重新持有后台资源。
- 新增 `scripts/check-startup-flow.ps1` 并接入项目标准门禁，防止重复图标或阻塞式音频初始化回归。

### 验证

- 启动链路定向检查、项目标准检查与 `git diff --check`：`passed`。
- debug 主 HAP：`passed`，4,655,374 bytes。
- debug ohosTest HAP：`passed`，5,639,856 bytes。
- release 主 HAP：`passed`，4,420,604 bytes。
- phone 模拟器 Hypium：`passed`，19/19，Failure 0，Error 0，`OHOS_REPORT_CODE: 0`。
- phone 冷启动：`passed`，系统启动图标后直接进入首页；启动 50ms 后回桌面并再次进入仍正常。
- 2in1 冷启动：`passed`，最新 debug HAP 可直接进入宽屏首页，快速退后台再进入正常。
- tablet：`blocked`，当前没有可用目标。

详细证据见 `docs/qa/2026-08-03-startup-flow.md`。

## 2026-08-02｜设置反馈项分组排序

- 状态：`done`
- 用户请求：把带开关的设置项放在一起、带箭头的设置项放在一起，并保持其余内容不变。

### 已完成改动

- “敲击反馈”调整为音效开关、振动反馈、浮动文字、音量、音色选择、自定义文字。
- 三个开关连续排列，音量作为视觉过渡，两个箭头入口连续排列。
- 仅移动现有设置项代码块，保留原有样式、间距、颜色、控件、回调和行为。

### 验证

- 设置项顺序断言、项目标准检查与 `git diff --check`：`passed`。
- debug 主 HAP：`passed`，4,648,798 bytes。
- debug ohosTest HAP：`passed`，5,635,128 bytes。
- release 主 HAP：`passed`，4,418,416 bytes。
- phone 模拟器 Hypium：`passed`，18/18，Failure 0，Error 0，`OHOS_REPORT_CODE: 0`。
- phone 视觉验收：`passed`，证据见 `docs/qa/2026-08-02-settings-feedback-order.md`。
- tablet、2in1 视觉验收：`blocked`，当前无对应设备。

## 2026-08-02｜设置实时响应式刷新

- 状态：`done`
- 用户请求：修复实时数据改动后设置页数值和状态不能即时刷新的问题，并统一覆盖所有设置项。

### 已完成改动

- `AppStore` 增加独立设置快照 API，`Index` 每次设置变化后立即替换 ArkUI `@State` 对象，再异步写入 Preferences。
- 音效、振动、浮动文字、音色、主题、自定义文字和音量统一为“内存更新、UI 快照更新、后台持久化”的顺序；写入失败继续显示本地存储异常提示。
- 音量仅在拖动结束或点击轨道时持久化，拖动过程中的滑块和百分比保持实时同步。
- 修复动态详情作为普通参数传入 `@Builder SettingRow` 后被局部更新复用的问题；音量、音色和自定义文字详情改为在 Builder 内直接读取响应式字段。
- 增加设置快照独立性及持久化完成前运行时状态已更新的 Hypium 回归用例。

### 验证

- 项目标准检查与 `git diff --check`：`passed`。
- debug 主 HAP：`passed`，4,648,798 bytes。
- debug ohosTest HAP：`passed`，5,635,128 bytes。
- release 主 HAP：`passed`，4,418,412 bytes。
- phone 模拟器 Hypium：`passed`，18/18，Failure 0，Error 0，`OHOS_REPORT_CODE: 0`。
- phone 设置交互：`passed`，音量、三个开关、音色、主题和自定义文字均即时刷新；证据见 `docs/qa/2026-08-02-settings-reactive-refresh.md`。
- tablet、2in1 视觉验收：`blocked`，当前无对应设备。

## 2026-08-02｜暂停图标配色优化

- 状态：`done`
- 用户请求：优化自动敲击暂停图标的颜色，使其适合首页暖木色页面。

### 已完成改动

- 移除会被 HarmonyOS 渲染为蓝色彩色 Emoji 的 `⏸` 字符。
- 使用 ArkUI 两条圆角竖线绘制分辨率无关的暂停图标；浅色主题使用 `DesignTokens.wood`，深色主题使用 `DesignTokens.accentDark`。
- 图标与“暂停”文字统一配色，保留原有按钮背景、暂停/继续逻辑和无障碍描述。
- 新增 `scripts/check-pause-icon.ps1` 并接入项目标准门禁，防止彩色 Emoji 回归。

### 验证

- 暂停图标定向检查：`passed`。
- 项目标准检查：`passed`。
- debug 主 HAP：`passed`，4,646,681 bytes。
- debug ohosTest HAP：`passed`，5,633,102 bytes。
- release 主 HAP：`passed`，4,417,669 bytes。
- phone 模拟器 Hypium：`passed`，17/17，Failure 0，Error 0，`OHOS_REPORT_CODE: 0`。
- phone 视觉验收：`passed`，截图见 `docs/qa/screenshots/2026-08-02-pause-icon-warm.jpeg`。
- tablet、2in1 视觉验收：`blocked`，当前无对应设备。

## 2026-08-02｜界面与状态同步修复

- 状态：`done`
- 用户请求：修复首页背景断层与木槌位置；让首页右上角跟随自定义文字并独立从 0 计数；日、周、月趋势默认显示当前周期；移除年趋势；修复开关越界及音量、文字不能即时刷新的问题。

### 已完成改动

- 首页浅色背景统一为与木鱼素材外围一致的 `#FAF4EF`，木槌基准位置由 `176vp` 上移至 `145vp`。
- `AppSettings` 持久化当前文字的今日计数基线；修改文字只重置首页文案计数，不清空每日记录、累计功德或历史趋势。
- 首页右上角改为“当前文字 + 当前文字计数”，设置页通过响应式副本即时刷新音量百分比和自定义文字。
- 趋势仅保留日、周、月，桶继续按时间升序排列，并在页面出现及周期切换后自动滚动到今日、本周、本月所在的最右端。
- 保持设置项原顺序和结构，将三个 Toggle 向左收进白色卡片，并通过响应区域保证至少 `48vp` 的触控目标。
- 趋势只在初次显示和用户切换周期时定位到末端，自动敲击刷新数据时不再打断用户查看历史。
- 自定义文字编辑草稿与后台统计刷新隔离，设置持久化写入串行执行，避免快速连续修改乱序覆盖。
- 清除统计时同步上报基线保存失败；启动时自动修复大于今日统计的异常旧基线。
- 增加文字计数重置、重复保存、跨日、清除统计与重启恢复回归断言，设置乱序写入测试，以及日周月末桶契约测试。

### 验证

- 项目标准检查：`passed`。
- debug 主 HAP：`passed`，4,639,270 bytes。
- debug ohosTest HAP：`passed`，5,630,818 bytes。
- release 主 HAP：`passed`，4,414,576 bytes。
- phone 模拟器 Hypium：`passed`，16/16，Failure 0，Error 0，`OHOS_REPORT_CODE: 0`。
- phone 视觉与交互：`passed`，证据见 `docs/qa/2026-08-02-ux-regression.md`。
- tablet、2in1 实机视觉验收：`blocked`，当前无对应设备。

## 2026-08-01｜ArkTS 语法修复

- 状态：`done`
- 用户请求：按照 HarmonyOS ArkTS/ArkUI 语法规范修复当前工作区编译错误。

### 已完成改动

- 将目标次数异步更新包装为显式 `void` 回调，避免把 `Promise<void>` 返回给 ArkUI 组件事件属性。
- 移除 ohosTest 对已删除 `HitFeedbackPlan` 模型的测试注册，并将响应式断点测试迁移到当前共享 `DesignTokens`。

### 验证

- 项目标准检查：`passed`。
- debug 主 HAP：`passed`，4,623,712 bytes。
- release 主 HAP：`passed`，4,408,428 bytes。
- debug ohosTest HAP：`passed`，5,608,646 bytes。
- phone 模拟器 Hypium：`passed`，13/13，Failure 0，Error 0，`OHOS_REPORT_CODE: 0`。
- 签名身份未配置，产物保持 unsigned HAP。

## 2026-07-30｜用户反馈改版

- 状态：`done`
- 用户请求：逐项修复测试反馈，并吸收同类产品的大触控区、可见音色和自动敲击优点，同时彻底排除广告与联网冗余。

### 已完成改动

- 统一为普通用户，移除首启三用户选择和设置页用户切换，兼容迁移旧偏好。
- 首页顶部仅保留今日功德；浮字不再追加次数，并在 760ms 后自动消退。
- 删除限时档；自由、目标、自动三档互斥，自动档支持再次点击关闭，切档立即停止。
- 目标档增加 108 次进度、完成反馈和额外敲击拦截。
- 实现日、周、月、年四套真实统计口径、标题、摘要和图表桶。
- 实现跟随系统、浅色、深色完整主题，以及低沉、清脆、柔和三音色可见选择和本地试听。
- 将木鱼主体与 ArkUI 木槌拆分；手动和自动共用同一敲击序列与动画反馈。
- 保留用户原素材，新增仅移除静态木槌的浅色/深色木鱼主体派生资源。
- 记录小米 15 上同类产品只读观察结果；不复制其品牌素材，也不引入广告、登录、排行或外部跳转。

### 验证

- 项目标准检查与外部 HarmonyOS 标准检查：`passed`。
- debug 主 HAP：`passed`，5,166,513 bytes。
- release 主 HAP：`passed`，4,986,221 bytes。
- ohosTest HAP：`passed`，6,218,038 bytes。
- Hypium：`passed`，14/14，Failure 0，Error 0。
- 代码与权限扫描：`passed`，主模块仅申请振动权限，未发现网络权限、HTTP、WebView 或广告 SDK。
- phone 模拟器：主题、音色面板、统计周期标题与自动切档停止已验证；目标 108 封顶由 Hypium 回归用例验证。
- tablet、2in1：`blocked`，当前没有对应设备。

### 遗留风险

- 未配置签名身份，产物保持 unsigned HAP。
- 模拟器无法客观证明实体扬声器音色与真实振感。
- 模拟器中另一应用偶发抢占自动化输入焦点，因此未将目标完成坐标点击作为运行态证据；封顶与额外敲击拦截由可复现的 Hypium 用例覆盖。

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
