# 功德木鱼项目规则

本文件适用于项目根目录及全部子目录。

## 项目边界

- 项目类型：HarmonyOS Stage 模型 ArkTS/ArkUI 单机应用。
- 业务源码：`entry/src/main/ets/`。
- 页面位于 `pages/`，复用 UI 位于 `components/`，持久化位于 `repositories/`，系统能力位于 `services/`。
- 应用资源：`entry/src/main/resources/`。
- 不添加网络、后端、广告、支付、登录或云同步。

## 标准流程

1. 开始前阅读 `README.md`、`tasks.md`、`changes.md`、`design.md` 和 `design-qa.md`。
2. `tasks.md` 状态只使用 `pending`、`in_progress`、`done`、`blocked`。
3. 业务行为先写失败测试，再写最小实现。
4. 使用明确 ArkTS 类型，禁止 `any`。
5. 页面负责组合，存储和系统能力不得散落在页面中。
6. 完成后执行静态检查、Hypium、debug/release 构建和可用设备验证。

## 多设备与设计

- 支持 phone、tablet、2in1。
- 手机对照用户批准的高保真稿；宽屏使用断点、限宽和双栏重排。
- 共享颜色、间距、字号和资源集中管理。
- 触控目标不小于 48vp，选中态不能只依赖颜色。

## 安全

- 不提交签名口令、私钥、令牌、设备隐私、构建缓存和 IDE 本地配置。
- 未经用户明确要求，不修改 `com.max.muyu`、版本发布状态或签名身份。

