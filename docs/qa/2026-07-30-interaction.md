# 2026-07-30 交互验收清单

API 24 phone 模拟器 `127.0.0.1:5555` 已完成核心运行态验收；tablet、2in1 仍因无对应目标而 `blocked`。

| 检查 | 状态 | 证据 |
| --- | --- | --- |
| 首次启动模式选择并进入首页 | passed | `2026-07-30-phone-first-launch.jpeg`、`phone-mode-bottom.jpeg`、`phone-home.jpeg` |
| 快速连续敲击、浮动文字、今日/累计/最大单日同步 | passed | `2026-07-30-phone-rapid-hits-fixed.jpeg`，6/6/6 一致 |
| 统计摘要与最近 7 日补零 | passed | `2026-07-30-phone-stats.jpeg` |
| 设置页、开关、素材人物与原始导航图标 | passed | `2026-07-30-phone-settings.jpeg` |
| 强制停止后重启、跳过首启页、计数持久化 | passed | `2026-07-30-phone-restart-persisted.jpeg`，重启后仍为 6 |
| 乱序持久化、模式状态机、目标停止、重复自动定时器 | passed | Hypium 10/10 |
| 三音色听感与真实振感 | limited | 模拟器可验证调用和开关，不能客观证明扬声器听感与实体振动 |
| tablet、2in1 Medium/Expanded 实际显示 | blocked | 当前没有对应设备；断点和限宽逻辑已通过编译与静态门禁 |

运行截图目录：`docs/qa/screenshots/`。前台状态摘录见 `docs/qa/2026-07-30-foreground.txt`。

## 用户反馈改版复验

| 检查 | 状态 | 证据 |
| --- | --- | --- |
| 单普通用户首页、顶部仅今日功德、木鱼/木槌分层 | passed | `2026-07-30-feedback-home-dark.jpeg` |
| 浮动文字不追加敲击次数，760ms 后移除 | passed | `WoodenFishView` 统一序列与定时清理；debug 编译通过 |
| 自动档再次点击关闭、切换自由/目标立即停止 | passed | 运行态计数 17→20，切回自由后等待 2.3s 仍为 20；Hypium 回归用例 |
| 目标达到 108、显示完成状态并阻止额外敲击 | passed | Hypium `countsRapidHitsAndStopsExactlyAtTarget` |
| 日、周、月、年切换生成不同口径 | passed | 运行态标题依次为“近 7 日每日趋势”“近 8 周趋势”“近 12 月趋势”“近 5 年趋势”；Hypium 聚合用例 |
| 浅色、深色与跟随系统完整换肤 | passed | `2026-07-30-feedback-settings-light.jpeg`、`2026-07-30-feedback-settings-dark.jpeg`；ThemeResolver 用例 |
| 低沉、清脆、柔和三音色可见选择 | passed | `2026-07-30-feedback-sound-picker.jpeg` |
| 手动与自动共用木槌、回弹、波纹和浮字序列 | passed | Hypium `incrementsOneSharedHitSequenceForManualAndAutoFeedback`；首页运行截图 |
| 无广告与联网能力 | passed | `module.json5` 仅声明 `ohos.permission.VIBRATE`；主模块扫描无广告 SDK、HTTP、WebView |
| 实体音色与真实振感 | limited | 模拟器不能客观证明扬声器听感与物理振感 |
| tablet、2in1 Medium/Expanded 实际显示 | blocked | 当前没有对应设备 |

模拟器中另一个已安装应用偶发抢占坐标自动化焦点，因此目标完成未采用不稳定的坐标点击结果；对应状态机行为由 14/14 Hypium 中的确定性回归测试覆盖。
