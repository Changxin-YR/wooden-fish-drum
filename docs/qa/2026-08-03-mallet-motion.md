# 木槌造型与敲击动画 QA

## 环境

- phone：`127.0.0.1:5555`，1320 x 2856。
- 2in1：`127.0.0.1:5557`，3120 x 2080。
- 包名 / Ability：`com.max.muyu` / `EntryAbility`。

## 结果

| 检查项 | 结果 | 证据 |
| --- | --- | --- |
| 木槌为参考图水滴形造型且无矩形背景 | passed | `entry/src/main/resources/base/media/muyu_mallet.png` 为 RGBA 857 x 189，alpha 范围 0..255，四角 alpha 为 0 |
| phone 静止时槌头位于木鱼冠部上方 | passed | `screenshots/2026-08-03-mallet-phone-idle.jpeg` |
| phone 敲击时产生真实位置、木鱼压缩与声波变化 | passed | 并行连续敲击与抓屏捕获 `screenshots/2026-08-03-mallet-phone-motion.jpeg`，计数从 135 增到 136 |
| 2in1 宽屏静止位置与木鱼冠部对齐 | passed | `screenshots/2026-08-03-mallet-2in1-idle.jpeg` |
| 静态门槛 | passed | `scripts/check-mallet-layout.ps1` |
| Hypium | passed | 24/24，Failure 0，Error 0，`OHOS_REPORT_CODE: 0` |
| debug / ohosTest / release | passed | 4,904,772 / 5,887,225 / 4,656,197 bytes |
| tablet | blocked | 当前无 tablet 目标 |

## 说明

浅色与深色木鱼资源的冠部高度不同，宽屏 `ImageFit.Cover` 还会改变纵向裁切。组件因此根据主题和自身宽度选择静止基准，并根据宽度选择接触角度与纵向落差，使 phone 与 2in1 都不会悬空或穿入鱼身。

phone 上另一个应用偶发抢占自动化输入焦点，因此运动帧通过在木鱼物理边界内连续敲击并并行抓屏获得；计数和动画反馈同时变化，证明截图位于真实敲击序列中。
