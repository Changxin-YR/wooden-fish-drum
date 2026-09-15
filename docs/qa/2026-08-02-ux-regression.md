# 2026-08-02 界面与状态同步回归

## 环境

- HarmonyOS 6.1.1 API 24 phone 模拟器：`127.0.0.1:5555`
- 包名 / 测试模块：`com.max.muyu` / `entry_test`
- 签名：未修改签名身份，产物保持 unsigned HAP

## 自动验证

| 项目 | 结果 | 证据 |
| --- | --- | --- |
| 项目标准检查 | passed | `scripts/check-standard.ps1` 退出码 0 |
| debug 主 HAP | passed | `entry-default-unsigned.hap`，4,639,270 bytes |
| debug ohosTest HAP | passed | `entry-ohosTest-unsigned.hap`，5,630,818 bytes |
| release 主 HAP | passed | `entry-default-unsigned.hap`，4,414,576 bytes |
| Hypium | passed | Tests run 16，Pass 16，Failure 0，Error 0，`OHOS_REPORT_CODE: 0` |

`resetsOnlyHomeTextCountWhenTextChanges` 覆盖文字切换后归零、重复保存不归零、跨日计数、清除统计后重新计数，以及从同一本地存储重新初始化后的基线恢复。`reportsAndRepairsFailedBaselineResetAfterClearingStats` 覆盖基线保存失败上报与下次启动自愈。`persistsLatestSettingsWhenWritesCompleteOutOfOrder` 覆盖连续设置保存的乱序完成场景。`buildsChronologicalDayWeekAndMonthViewsEndingAtCurrentPeriod` 覆盖日、周、月桶按时间升序且当前周期位于末尾。

## phone 视觉与交互

| 验收项 | 结果 | 截图 |
| --- | --- | --- |
| 首页背景无色彩断层，木槌上移 | passed | `screenshots/2026-08-02-home-text-zero.jpeg` |
| 首页右上角显示“今日好运 0”，累计统计仍为 188 | passed | `screenshots/2026-08-02-home-text-zero.jpeg` |
| 设置页自定义文字即时显示“今日好运” | passed | `screenshots/2026-08-02-settings-text-current.jpeg` |
| 音量拖动后百分比立即由 25% 更新为 55% | passed | `screenshots/2026-08-02-volume-live-fixed.jpeg` |
| 三个开关完整位于白色卡片内 | passed | `screenshots/2026-08-02-settings-text-current.jpeg` |
| 日趋势默认显示今日 `08/02` | passed | `screenshots/2026-08-02-stats-day-latest.jpeg` |
| 周趋势默认显示当前周 `07/27` | passed | `screenshots/2026-08-02-stats-week-latest.jpeg` |
| 月趋势默认显示本月 `08月` | passed | `screenshots/2026-08-02-stats-month-latest.jpeg` |
| 趋势切换仅保留日、周、月 | passed | 三张趋势截图 |

趋势桶保持从过去到当前的时间升序；页面初次进入和切换周期时定位到最右端，用户向右滑动内容即可查看更早数据。

## 未覆盖设备

- tablet：`blocked`，当前无可用目标。
- 2in1：`blocked`，当前无可用目标。
