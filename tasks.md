# 任务清单

状态定义：`pending`、`in_progress`、`done`、`blocked`。

## 当前任务

### T-2026-07-29-001 功德木鱼 V1.0

- 状态：`blocked`
- 目标：完成 API 24 原生 HarmonyOS 单机功德木鱼 V1.0。
- 范围：模式选择、敲击反馈、会话模式、设置、统计、本地持久化和三类设备适配。

检查项：

- [x] 审计规格、参考图、HarmonyOS 技能和本机 SDK。
- [x] 完成标准 Stage 工程与测试模块。
- [x] 完成五个功能阶段。
- [x] 通过项目静态门禁与外部标准检查。
- [x] 通过 debug、ohosTest 与 release 编译构建。
- [ ] 在设备上运行 Hypium（`blocked`：`hdc list targets` 返回 `[Empty]`）。
- [ ] 完成 phone、tablet、2in1 交互验证（`blocked`：当前无连接设备或模拟器）。

## 后续任务

### T-2026-07-29-002 多设备实机回归

- 状态：`blocked`
- 目标：分别覆盖 phone、tablet、2in1 实际运行分支。
- 前置条件：具备对应模拟器或真机。
- 恢复方式：连接 API 24 phone、tablet、2in1 设备，安装主 HAP 与测试 HAP，执行 `OpenHarmonyTestRunner` 并按 `docs/qa/2026-07-30-interaction.md` 回归。
