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
