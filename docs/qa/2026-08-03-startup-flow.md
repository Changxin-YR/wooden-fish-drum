# 2026-08-03 冷启动图标闪现优化验证

## 根因与修复

`EntryAbility` 的 HarmonyOS 系统启动窗口与 `Index` 的应用内加载页曾连续绘制同一张 `app_icon`。图标中的木槌在短暂小尺寸显示时容易被看成放大镜，应用内加载页还会等待音频资源，因而强化了闪现感。

修复后保留系统启动窗口；`Index` 加载阶段只绘制首页背景。本地状态同步完成后立即进入首页，再异步初始化音频。音频候选资源通过 `InitializationSlot` 管理，退后台或新初始化会使旧候选失效并释放。

## 自动化结果

| 检查 | 结果 | 证据 |
| --- | --- | --- |
| 启动链路定向检查 | `passed` | 系统启动配置保留；`Index` 无 `app_icon`；无 awaited audio init |
| 项目标准检查 | `passed` | Pause icon、startup flow、standard check 全部通过 |
| debug 主 HAP | `passed` | 4,655,374 bytes |
| debug ohosTest HAP | `passed` | 5,639,856 bytes |
| release 主 HAP | `passed` | 4,420,604 bytes |
| phone Hypium | `passed` | Tests run 19，Pass 19，Failure 0，Error 0，`OHOS_REPORT_CODE: 0` |
| 音频生命周期 | `passed` | 旧候选丢弃、当前资源发布、取消取回当前资源用例通过 |

## 设备结果

| 设备 | 状态 | 结果 |
| --- | --- | --- |
| phone | `passed` | 强停后冷启动，100ms 帧为 HarmonyOS 系统启动图标，后续直接进入首页；启动 50ms 后回桌面再进入正常 |
| 2in1 | `passed` | 安装同一 debug HAP 后冷启动，并完成启动 50ms 后回桌面再进入，宽屏首页正常 |
| tablet | `blocked` | 当前没有可用 tablet 目标 |

截图：

- `docs/qa/screenshots/2026-08-03-startup-system.jpeg`
- `docs/qa/screenshots/2026-08-03-startup-home.jpeg`
- `docs/qa/screenshots/2026-08-03-startup-2in1-home.jpeg`
