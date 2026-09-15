# 2026-08-02 设置实时响应式刷新验收

## 环境

- HarmonyOS 6.1.1 API 24 phone 模拟器：`127.0.0.1:5555`
- 包名 / 测试模块：`com.max.muyu` / `entry_test`
- 签名：未修改签名身份，产物保持 unsigned HAP

## 根因复现

修复前在设置页把音量从 50% 拖到 25% 后，UI 层级同时出现 `Slider 0.250000` 和旧文本 `50%`。运行时设置已经变化，但音量、自定义文字和音色摘要作为普通参数传入 `@Builder SettingRow`，ArkUI 局部更新继续复用旧 Builder 参数。

## 自动验证

| 项目 | 结果 | 证据 |
| --- | --- | --- |
| 项目标准检查 | passed | `scripts/check-standard.ps1` 退出码 0，包含暂停图标定向检查 |
| `git diff --check` | passed | 无空白错误，仅有 Git 行尾转换提示 |
| debug 主 HAP | passed | `entry-default-unsigned.hap`，4,648,798 bytes |
| debug ohosTest HAP | passed | `entry-ohosTest-unsigned.hap`，5,635,128 bytes |
| release 主 HAP | passed | `entry-default-unsigned.hap`，4,418,412 bytes |
| Hypium | passed | Tests run 18，Pass 18，Failure 0，Error 0，`OHOS_REPORT_CODE: 0` |

新增 `createsIndependentSettingsSnapshotsForImmediateUiRefresh`，覆盖设置快照引用与字段独立性。新增 `updatesRuntimeSettingsBeforePersistenceCompletes`，覆盖主题和自定义文字在 Preferences 写入完成前已经更新运行时状态。

## phone 交互

| 验收项 | 结果 | 证据 |
| --- | --- | --- |
| 音量滑块与百分比实时一致 | passed | 同一 UI 层级为 `Slider 0.600000` 与 `60%`；截图 `screenshots/2026-08-02-settings-volume-reactive.jpeg` |
| 音效、振动、浮动文字开关即时刷新 | passed | 连续点击后同一 UI 层级三个 Toggle 均立即由 `true` 变为 `false`，随后已恢复开启 |
| 音色摘要即时刷新 | passed | 选择清脆后同一 UI 层级立即显示“木鱼 · 清脆”，验收后恢复柔和 |
| 主题即时刷新 | passed | 点击深色后页面根背景立即变为 `#171513`，验收后恢复浅色 |
| 自定义文字摘要即时刷新 | passed | 保存压力-1 后设置行同一 UI 层级立即显示“压力-1”，首页读取同一新文字 |
| 设置恢复 | passed | 验收结束时为柔和音色、50% 音量、压力-1、浅色、三个反馈开关开启 |

设备上另一个本地图片工具会偶发抢占自动化输入焦点。本次只采信根节点 `bundleName` 为 `com.max.muyu` 的 UI 层级，并在每组操作前显式启动本应用。

## 未覆盖设备

- tablet：`blocked`，当前无可用目标。
- 2in1：`blocked`，当前无可用目标。
