# V2.1 上架准备检查

检查日期：2026-07-31。

## 已通过

- HarmonyOS Stage 模型 ArkTS/ArkUI，API 24；`module.json5` 声明 phone、tablet、2in1。
- 包名保持 `com.max.muyu`，版本保持 `1.0.0`，未修改发布身份。
- 主模块只申请 `ohos.permission.VIBRATE`；未申请网络权限。
- 未发现 HTTP/HTTPS、WebView、广告、支付、登录、云同步或用户画像 SDK 业务能力。
- 本地标准检查通过；外部标准检查 22 项通过、0 项失败。
- debug、release、ohosTest 构建退出码为 0；设备 Hypium 47/47，Failure 0、Error 0。
- API 24 phone 模拟器已验证练习、记录、设置、四个合规页面、返回和清除二次确认。
- 应用内隐私说明与实际行为一致；用户须知不承诺宗教、医疗或心理健康功效。

## 发布阻塞

| 项目 | 状态 | 恢复条件 |
| --- | --- | --- |
| release 签名 | `blocked` | 发布主体在 DevEco Studio/构建配置中绑定真实证书、Profile 和签名身份；不得提交口令或私钥。 |
| 应用备案 | `blocked` | 发布主体完成适用备案并提供可核验信息；应用内不展示未确认编号。 |
| 隐私政策 URL | `blocked` | 在 AppGallery Connect 填写可公开访问、内容与应用内说明一致的正式 URL。 |
| 素材授权 | `blocked` | 为用户提供的木鱼、念珠、一炷香、图标和音频保存原创或商业使用授权证明。 |
| 木鱼源图 | `blocked` | 提供无烘焙点击光圈版本，避免静态素材与 ArkUI 动态反馈叠加。 |
| 一炷香源图 | `blocked` | 提供香体与烟雾分层资源，再完成燃烧和减少动画模式验收。 |
| tablet 运行证据 | `blocked` | 连接 API 24 tablet 模拟器或真机，验证 Medium、横屏、窗口缩放和系统字体放大。 |
| 2in1 运行证据 | `blocked` | 连接 API 24 2in1 模拟器或真机，验证 Expanded、横屏、窗口缩放和系统字体放大。 |

## 构建证据

- debug unsigned HAP：7,396,792 bytes。
- ohosTest unsigned HAP：8,185,899 bytes。
- release unsigned HAP：6,938,600 bytes。
- release 构建的 `No signingConfig found for product default` 是真实发布阻塞，不视为已签名产物。
- release 构建提示尚未启用混淆；当前不把混淆作为功能正确性门禁，正式发布策略需在签名配置完成后由发布主体确认并执行完整回归。

外部标准检查器提示缺少 `entry/src/main/ets/common`。项目现有 `models/`、`constants/`、`utils/`
已承担强类型模型、常量和纯逻辑职责；为避免无收益迁移风险，本版本保留现有目录结构。
