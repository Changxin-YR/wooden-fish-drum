# UI 素材清单

所有生产图片均优先来自用户提供的原始高保真图。原始资源均保留；既有资源仅做像素级矩形裁切，新木鱼主体派生资源仅移除原图中的静态木槌，未改动木鱼纹理、色彩或构图。

| 最终资源 | 原始文件 | 裁切区域（x,y,w,h） | 用途 |
| --- | --- | --- | --- |
| `AppScope/resources/base/media/app_icon.png` | `codex-clipboard-94a7e43e-e486-4787-95e8-d3c129cc7a22.png` | 91,92,360,360 | 桌面应用图标 |
| `entry/src/main/resources/base/media/app_icon.png` | 同上 | 91,92,360,360 | Ability 与启动图标 |
| `muyu_brand.png` | `codex-clipboard-a768e422-bbdd-490d-911a-21efe6922759.png` | 285,62,370,235 | 品牌区与浅色木鱼 |
| `mode_programmer.png` | 同上 | 92,620,235,235 | 程序员模式卡 |
| `mode_monk.png` | 同上 | 105,906,220,240 | 僧侣模式卡 |
| `mode_general.png` | 同上 | 106,1200,220,235 | 普通用户模式卡 |
| `muyu_dark.png` | `codex-clipboard-6f2ca1a5-fbed-43a8-93f5-9cdcf2067cfc.png` | 180,448,575,420 | 深色首页木鱼 |
| `muyu_light.png` | `codex-clipboard-ddfac7ff-b094-4173-83c6-afeb6ff3f07d.png` | 690,595,300,240 | 浅色木鱼备选素材 |
| `nav_home.png` | `codex-clipboard-94a7e43e-e486-4787-95e8-d3c129cc7a22.png` | 537,193,150,170 | 底部导航：首页原始图标 |
| `nav_stats.png` | 同上 | 706,193,150,170 | 底部导航：统计原始图标 |
| `nav_settings.png` | 同上 | 875,193,150,170 | 底部导航：设置原始图标 |
| `muyu_body_light.png` | `muyu_brand.png` | 派生编辑：仅移除静态木槌 | 浅色主题木鱼主体 |
| `muyu_body_dark.png` | `muyu_dark.png` | 派生编辑：仅移除静态木槌 | 深色主题木鱼主体 |

音频使用同机已有 HarmonyOS 工程中的本地短 WAV 资源复用并按低沉、清脆、柔和语义命名，不请求网络资源。

木槌由 ArkUI 图形独立绘制和旋转，不使用新下载素材；敲击时只移动木槌并轻微缩放木鱼主体。

## V2.1 用户素材（2026-07-31）

三张 941 x 1672 RGB 页面稿仅作为 phone 高保真对照，不打包为整页背景：

- `codex-clipboard-aa7c4510-8c54-4174-8774-2af72cbe1d70.png`：练习页参考。
- `codex-clipboard-ca06f5f9-701f-456b-9a26-f151fc559084.png`：记录页参考。
- `codex-clipboard-bfbdf7f2-beb5-46c1-817a-5e48fb55b14a.png`：设置页参考。

三张 1024 x 1536 ARGB 主体图已使用相同的可复现规则处理：忽略 alpha 小于 8 的外围散点确定主体边界，向外扩展 24px，再从原图裁切，边界内原始 RGB 与 alpha 不变。

| 最终资源 | 用户原始文件 | 裁切区域（x,y,w,h） | 授权状态 | 用途与限制 |
| --- | --- | --- | --- | --- |
| `practice_wooden_fish.png` | `codex-clipboard-341ad948-a57d-452d-89fe-c72928df3054.png` | 192,460,771,646 | 待用户提供原创或商用授权证明 | 木鱼原型；点击光圈已烘焙，发布前需无光圈静止源图 |
| `practice_beads.png` | `codex-clipboard-2f33a980-e9a4-4c05-a283-c77cd51c4f3e.png` | 216,191,604,1095 | 待用户提供原创或商用授权证明 | 念珠基础层；逐珠高亮由 ArkUI 热点层实现 |
| `practice_incense.png` | `codex-clipboard-0e62e54a-c38a-4a3a-8b39-55d61ae7d863.png` | 144,67,759,1329 | 待用户提供原创或商用授权证明 | 一炷香原型；主体和烟雾未分层，发布前需分层源图 |

当前环境未提供内置图像编辑工具，且未获准使用需要 API Key 的 CLI 回退，因此未对木鱼纹理、光圈或香烟雾做生成式修补。原型开发可使用上述裁切图；“无光圈木鱼”“香体/烟雾分层”和“商用授权证明”在发布验收中保持 `blocked`。

## 2026-07-31 深浅主题 UI 基准

用户提供了首页、练习记录和设置页各一套浅色/深色 phone 稿。为避免临时附件丢失且控制仓库体积，项目在 `docs/ui/reference-2026-07-31/` 保存 471px 宽、JPEG 质量 88 的 QA 缩略图，总计约 270 KB。缩略图不打包进 HAP，也不作为整页背景。

| QA 缩略图 | 用户原始文件 | 用途 |
| --- | --- | --- |
| `home-light.jpg` | `codex-clipboard-f066878d-7e27-4a06-ad4d-46f86aa633cf.png` | 浅色首页基准 |
| `home-dark.jpg` | `codex-clipboard-bbadb233-a294-4388-9bc5-1f90452085b7.png` | 深色首页基准 |
| `stats-light.jpg` | `codex-clipboard-c1c83073-7e9a-4bb1-8164-8f5c4e097e78.png` | 浅色记录基准 |
| `stats-dark.jpg` | `codex-clipboard-d852d31c-e7cf-4535-826a-d2da4da9ab02.png` | 深色记录基准 |
| `settings-light.jpg` | `codex-clipboard-dec4c210-1cf8-455d-8002-b94530e1c49a.png` | 浅色设置基准 |
| `settings-dark.jpg` | `codex-clipboard-f097d64a-9632-4282-9f21-7227c2004b9c.png` | 深色设置基准 |
