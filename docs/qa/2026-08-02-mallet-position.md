# 2026-08-02 木锤位置调整验收

## 环境

- HarmonyOS 6.1.1 API 24 phone 模拟器：`127.0.0.1:5555`
- 包名 / Ability：`com.max.muyu` / `EntryAbility`
- 木锤方案：B，`x: '53%'`、`y: 45`、静止及复位角度 `-4` 度

## 自动验证

| 项目 | 结果 | 证据 |
| --- | --- | --- |
| 木锤布局回归脚本 | passed | `scripts/check-mallet-layout.ps1` 退出码 0 |
| 项目标准检查 | passed | `scripts/check-standard.ps1` 退出码 0 |
| debug 主 HAP | passed | `entry-default-unsigned.hap`，4,639,270 bytes |
| debug ohosTest HAP | passed | `entry-ohosTest-unsigned.hap`，5,630,818 bytes |
| release 主 HAP | passed | `entry-default-unsigned.hap`，4,414,576 bytes |
| Hypium | passed | Tests run 16，Pass 16，Failure 0，Error 0，`OHOS_REPORT_CODE: 0` |

## phone 视觉与交互

| 验收项 | 结果 | 证据 |
| --- | --- | --- |
| 静止位置采用 B 方案 | passed | `screenshots/2026-08-02-mallet-position-b.jpeg` |
| 点击木鱼触发计数 | passed | 布局树由“本次已敲 0 次”更新为“本次已敲 1 次” |
| 击打动画产生明确画面变化 | passed | `screenshots/2026-08-02-mallet-hit-2.png` 与 `screenshots/2026-08-02-mallet-reset-2.png` 的木锤区域有 89.97% 像素变化 |
| 连续击打后精确复位 | passed | `screenshots/2026-08-02-mallet-reset.png` 与 `screenshots/2026-08-02-mallet-reset-2.png` 的木锤区域像素差异为 0% |

击打阶段原有 `-38` 度、回弹阶段 `-6` 度及动画时长、位移均保持不变。动画结束后恢复 `y: 45`、`-4` 度，不产生累计偏移。

## 未覆盖设备

- tablet：`blocked`，当前无可用目标。
- 2in1：`blocked`，当前无可用目标。
