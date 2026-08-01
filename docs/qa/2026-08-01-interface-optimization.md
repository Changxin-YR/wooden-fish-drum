# 界面优化与修复验收

检查日期：2026-08-01。

## 环境

- 工程：HarmonyOS Stage、ArkTS/ArkUI、HarmonyOS 6.0.2 API 22。
- phone 目标：`127.0.0.1:5555`。
- 设备参数：`const.ohos.apiversion=22`，`const.product.software.version=emulator 6.0.0.130(SP7DEVC00E130R4P11)`。
- 包名：`com.max.muyu`；应用显示名称：`静心木鱼`。
- 设备类型声明：phone、tablet、2in1。

## 改动与验收

| 改动点 | 涉及文件 | 验证方式 | 结果 |
| --- | --- | --- | --- |
| 统一主题、沉浸式和安全区 | `ThemePalette.ets`、`WindowAppearanceService.ets`、`EntryAbility.ets`、`Index.ets` | 深浅色逐页截图；布局树检查根背景和系统栏；双向切换 | `passed` |
| 开关不溢出 | `SettingsPage.ets` | API 22 phone 深浅色截图；Toggle 边界均在 60x48vp 外层容器内 | `passed` |
| 主题开关递归回调 | `SettingsPage.ets`、`ThemeResolver.ets` | 修复前日志复现一次点击依次产生 `true`、`false`；改为受控显示后深色 `checked=true`、浅色 `checked=false` | `passed` |
| 自定义文字即时刷新和持久化 | `FeedbackText.ets`、`AppStore.ets`、`SettingsPage.ets`、`Index.ets` | Hypium 保存/冷启动回归；页面统一消费 `feedbackText` | `passed` |
| 可选目标和再来一次 | `AppModels.ets`、`SettingsMigration.ets`、`PracticeController.ets`、`PracticeControlDock.ets`、`HomePage.ets` | Hypium 校验预设、自定义正整数、达标封顶、额外敲击拦截和重置 | `passed` |
| 右上木槌和透明木鱼 | `muyu_body_transparent.png`、`WoodenFishView.ets` | 深浅色首页截图；透明像素检查；手动运行查看 90ms/180ms 动画 | `passed` |
| 八档趋势 | `Enums.ets`、`StatsPeriodService.ets`、`StatsPage.ets` | Hypium 范围、桶数和聚合边界；API 22 页面显示八个 48vp 档位，默认本日 | `passed` |
| 应用名称和最小权限 | AppScope/entry `string.json`、`module.json5`、`check-standard.ps1` | 桌面显示“静心木鱼”；静态扫描仅有 `ohos.permission.VIBRATE` | `passed` |

## 构建与测试

| 门禁 | 结果 | 证据 |
| --- | --- | --- |
| 标准检查 | `passed` | `scripts/check-standard.ps1` 退出码 0 |
| debug | `passed` | unsigned HAP，8,093,191 bytes |
| ohosTest 构建 | `passed` | unsigned HAP，8,843,879 bytes |
| API 22 Hypium | `passed` | Tests run 54，Pass 54，Failure 0，Error 0，`OHOS_REPORT_CODE: 0` |
| release | `passed` | unsigned HAP，7,593,487 bytes |
| 差异检查 | `passed` | `git diff --check` 无空白错误 |

构建中的 `No signingConfig found for product default` 为预期发布阻塞：本次按约束未修改签名身份。ohosTest 的 `start_window_background` 重复资源提示来自测试模板合并，不影响主运行包。

## 截图索引

- 浅色：首页 `screenshots/muyu-api22-home-light.jpeg`，统计 `screenshots/muyu-api22-stats-light.jpeg`，设置 `screenshots/muyu-api22-settings-light.jpeg`。
- 深色：首页 `screenshots/muyu-api22-home-dark.jpeg`，统计 `screenshots/muyu-api22-stats-dark.jpeg`，设置 `screenshots/muyu-api22-settings-dark.jpeg`。
- 设置布局树：`muyu-api22-settings-light.json`、`muyu-api22-settings-dark.json`。

## 发布与多设备阻塞

- `blocked`：tablet 与 2in1 运行态截图。代码已保留 Medium/Expanded 断点，但 phone 结果不能替代对应设备验收。
- `blocked`：正式 release 签名、备案信息、AppGallery 隐私政策公开 URL 和素材商业授权证明，必须由发布主体提供。
- `blocked`：实体扬声器音色与真实振感，需要真机主观验收。
- 本轮未改 bundleName、版本发布状态或签名配置，未增加网络、广告、登录、支付或云同步能力。
