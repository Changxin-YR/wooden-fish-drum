# 2026-08-02 浮动提示冒泡堆叠验收

## 环境

- HarmonyOS 6.1.1 API 24 phone 模拟器：`127.0.0.1:5555`
- 包名 / Ability：`com.max.muyu` / `EntryAbility`
- 验收文字：`好运+1`

## 自动验证

| 项目 | 结果 | 证据 |
| --- | --- | --- |
| 冒泡布局回归脚本 | passed | `scripts/check-floating-bubbles.ps1` 退出码 0 |
| 木锤布局回归脚本 | passed | `scripts/check-mallet-layout.ps1` 退出码 0 |
| 项目标准检查 | passed | `scripts/check-standard.ps1` 退出码 0 |
| debug 主 HAP | passed | `entry-default-unsigned.hap`，4,648,798 bytes |
| debug ohosTest HAP | passed | `entry-ohosTest-unsigned.hap`，5,635,128 bytes |
| release 主 HAP | passed | `entry-default-unsigned.hap`，4,418,412 bytes |
| Hypium | passed | Tests run 18，Pass 18，Failure 0，Error 0，`OHOS_REPORT_CODE: 0` |

## phone 视觉与交互

| 验收项 | 结果 | 证据 |
| --- | --- | --- |
| 三次快速敲击同时显示三条提示 | passed | `screenshots/2026-08-02-floating-bubbles.jpeg` |
| 最新提示位于最下方 | passed | 截图中第三条 `好运+1` 位于固定下方锚点 |
| 旧提示向上排列并逐级淡化 | passed | 截图中上方两条透明度依次降低 |
| 木鱼和木锤无遮挡 | passed | 三条提示均位于木鱼主体和木锤上方 |
| 右上角计数无遮挡并同步增加 | passed | 截图显示 `好运+1 4` |
| 提示自动清理 | passed | 停止输入超过 900ms 后返回首页，提示层为空 |

提示数组仍只保留最后三条，生命周期仍为 760ms。木锤的 `x: '53%'`、`y: 45`、静止和复位 `-4` 度以及击打阶段参数未改变。

## 未覆盖设备

- tablet：`blocked`，当前无可用目标。
- 2in1：`blocked`，当前无可用目标。
