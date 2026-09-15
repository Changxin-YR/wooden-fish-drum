# 2026-08-03 系统栏沉浸式配色验收

## 环境

- SDK：HarmonyOS 6.1.1 API 24
- 包名 / Ability：`com.max.muyu` / `EntryAbility`
- phone：`127.0.0.1:5555`，1320 x 2856
- 2in1：`127.0.0.1:5557`，3120 x 2080

## 自动验证

| 项目 | 结果 | 证据 |
| --- | --- | --- |
| 系统栏定向门禁 | `passed` | `scripts/check-system-bars.ps1` |
| 项目标准检查 | `passed` | `scripts/check-standard.ps1` |
| debug 主 HAP | `passed` | 4,901,851 bytes |
| debug ohosTest HAP | `passed` | 5,887,225 bytes |
| release 主 HAP | `passed` | 4,654,355 bytes |
| phone Hypium | `passed` | Tests run 24，Pass 24，Failure 0，Error 0，`OHOS_REPORT_CODE: 0` |

## 视觉与交互验收

| 场景 | 结果 | 说明 |
| --- | --- | --- |
| phone 浅色首页冷启动 | `passed` | 状态栏延续首页背景，系统手势区延续浅色应用底栏 |
| phone 深色首页冷启动 | `passed` | 状态栏与图标切为深色方案，手势区延续深色应用底栏 |
| phone 深色/浅色设置 | `passed` | 主题切换后上下系统栏即时同步 |
| phone 隐私页 | `passed` | 沿用设置页系统栏方案，内容保持在上下安全区之间 |
| phone 统计页 | `passed` | 标签切换触发与非首页背景一致的状态栏方案 |
| 2in1 宽屏启动 | `passed` | 应用窗口完整显示，内容未与桌面标题栏或任务栏重叠 |
| tablet | `blocked` | 当前没有可用 tablet 目标 |

JPEG 像素采样受压缩影响存在 1 至 2 级偏差：深色首页顶部约为 `22,21,19`、底部约为 `34,33,29`；浅色设置/隐私页顶部约为 `245,240,234`、底部约为 `254,253,248`，与目标 token 一致。

## 截图

- `docs/qa/screenshots/2026-08-03-system-bars-fixed-phone.jpeg`
- `docs/qa/screenshots/2026-08-03-system-bars-final-dark-window.jpeg`
- `docs/qa/screenshots/2026-08-03-system-bars-final-dark-settings.jpeg`
- `docs/qa/screenshots/2026-08-03-system-bars-final-light-settings.jpeg`
- `docs/qa/screenshots/2026-08-03-system-bars-final-privacy.jpeg`
- `docs/qa/screenshots/2026-08-03-system-bars-final-2in1-latest.jpeg`
