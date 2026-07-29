# 功德木鱼

功德木鱼是一款使用 ArkTS 与 ArkUI 开发的 HarmonyOS NEXT 单机应用。应用不申请网络权限，不包含登录、广告、支付或云同步。

## 技术基线

- HarmonyOS 6.1.1 API 24
- Stage 模型
- ArkTS / ArkUI
- phone、tablet、2in1
- Preferences 本地持久化

## 构建

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -BuildMode debug
```

构建产物位于 `entry/build/default/outputs/default/` 下。设备测试与交互证据记录在 `docs/qa/`。

## 当前状态

V1.0 正在按五个阶段实施。真实进度、验证结果和遗留风险分别记录在 `tasks.md`、`changes.md` 与 `design-qa.md`。
