# 2026-08-02 设置反馈项分组排序验收

## 环境

- HarmonyOS 6.1.1 API 24 phone 模拟器：`127.0.0.1:5555`
- 包名：`com.max.muyu`

## 自动验证

| 项目 | 结果 | 证据 |
| --- | --- | --- |
| 设置项顺序断言 | passed | 六个标题各出现一次，源码索引严格递增 |
| 项目标准检查 | passed | `scripts/check-standard.ps1` 退出码 0 |
| debug 主 HAP | passed | 4,648,798 bytes |
| debug ohosTest HAP | passed | 5,635,128 bytes |
| release 主 HAP | passed | 4,418,416 bytes |
| Hypium | passed | Tests run 18，Pass 18，Failure 0，Error 0，`OHOS_REPORT_CODE: 0` |

## phone 视觉验收

UI 层级根节点为 `bundleName=com.max.muyu`。六项标题的纵向坐标依次为：音效开关 618、振动反馈 822、浮动文字 998、音量 1202、音色选择 1560、自定义文字 1764。

三个开关连续排列，音量位于中间作为视觉过渡，两个箭头入口连续排列。原有控件、间距、颜色和行为保持不变。截图见 `screenshots/2026-08-02-settings-feedback-order.jpeg`。

## 未覆盖设备

- tablet：`blocked`，当前无可用目标。
- 2in1：`blocked`，当前无可用目标。
