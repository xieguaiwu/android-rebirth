# F-Droid 收录提交指引（重生 Rebirth）

本目录包含提交流程所需的一切。你只需要一个 GitLab 账号，约 2 分钟完成。

> ✅ **已提交**：[MR !48687](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/48687)（2026-09-13），等待审核（排期常 1-4 周）。以下内容保留作记录；fork CI 因新账号身份验证不可用（零 job），本地 `fdroid lint`（2.4.5）exit 0。
>
> 🔄 **审核第一轮已响应**（2026-09-15，reviewer linsui）：MR 描述已换成官方 App Inclusion 模板+勾选框（标题 `New app: Rebirth`）、`commit` 钉全 hash、单 Build、NonFreeNet 补理由、元数据 rewritemeta 规范形；本地已复刻 CI 全套（rewritemeta/lint/checkupdates/tools/**fdroid build 端到端**/scanner）全绿，待维护者重触发上游 CI。本文件的原始提交说明保留作记录；`fdroiddata-mr-0001.patch` 已按当前分支重生成（基于最新上游 master，仍可直接 `git am`）。
>
> 🔄 **审核第二轮已响应**（2026-09-25）：①按 reviewer 要求 Rebirth 改 `subdir: app` + 删 `output`（prebuild/build 路径改 `../scripts/…`）②修复 CI `fdroid build` 失败（构建服务器无 `file(1)`）→ 发 v0.10.2（`od(1)` ELF 校验 + Go 缓存锚定仓库根）③5 app 联系邮箱换可达地址 `xieguaiwu@163.com` ④元数据在与 CI 完全一致的依赖集（ruamel.yaml 0.18.10 + fdroidserver master a35fddd）下重新 canonical 化。本地复刻 CI 全套（rewritemeta/lint/checkupdates/tools/schema/fastlane/**fdroid build 端到端**）全绿。

> ⚠️ **提交前先读「前置条件」**——本项目是候选中最特殊的一个：还有 P0 真机
> 验证未做，且它是唯一带「下载 Go 工具链」prebuild 步骤的构建。

## 前置条件（当前状态，2026-09-12）

| 条件 | 状态 |
|---|---|
| LICENSE（MIT） | ✅ 仓库根 |
| 依赖全 FOSS（Kotlin/Compose + 纯 Go 核心；无预编译二进制入库） | ✅ Go 工具链由 `prebuild` 下载（SHA-256 pin、fail-closed），核心全量源码构建 |
| Gradle wrapper 已提交 | ✅ |
| git tag `v0.10.2` | ✅ 已打并推送（2026-09-25） |
| fastlane 元数据（en-US + zh-CN，changelog 1000/1001/1002） | ✅ |
| 可复现构建验证（unsigned 双构建） | ✅ `047ab7be…bdc6`（tag v0.10.2） |
| **P0 真机验证（arm64 exec `.so`）** | ⏳ 核心风险点已过：真机截图（2026-09-12）显示引擎正常启动并渲染出身/天赋页；完整冒烟（整局/杀进程恢复/离线/LLM 叙事）仍待 |
| 真机截图替换 fastlane 占位图 | ✅ 已换（2026-09-12，1 张） |
| GitLab 账号 | ✅ 已注册（2026-09-12） |

## 已就绪的文件

| 文件 | 用途 |
|---|---|
| `com.xieguiawu.rebirth.yml` | fdroiddata metadata（类别 `Role-Playing Game`，已对照官方 categories.yml 验证）|
| `fdroiddata-mr-0001.patch` | 完整 commit 补丁（可直接 `git am`）|
| `../../fastlane/metadata/` | 双语商店文案（截图待真机替换）|

## 提交方法（二选一）

### 方法 A：Web 界面（最简单，无需本地 GitLab 配置）

1. 打开 https://gitlab.com/fdroid/fdroiddata
2. 点右上角 **Fork**（fork 到你自己的账号）
3. 在你的 fork 里打开 **Web IDE**（或 "+" → "New file"）
4. 新建路径：`metadata/com.xieguiawu.rebirth.yml`
5. 粘贴下方「metadata 内容」段的完整内容
6. 提交到新分支（如 `add-rebirth`）
7. 回到 fork 页面，点 **Create merge request**（目标 = fdroid/fdroiddata master）
8. MR 标题：`Add Rebirth (com.xieguiawu.rebirth)`
9. MR 描述：粘贴下方「MR 描述」段

### 方法 B：本地 git（需 GitLab 账号 SSH/HTTPS 认证）

```bash
git clone https://gitlab.com/fdroid/fdroiddata.git
cd fdroiddata
git checkout -b add-rebirth
git am /path/to/docs/fdroid/fdroiddata-mr-0001.patch   # 或手动创建 metadata 文件
git remote add mine <你的-fork-地址>
git push mine add-rebirth
# 在 GitLab 网页创建 MR: 你的 fork:add-rebirth → fdroid/fdroiddata:master
```

## metadata 内容

> 与 `com.xieguiawu.rebirth.yml` 逐字一致（改一处必改两处）。
> 校验：`bash scripts/validate-fdroid-metadata.sh docs/fdroid/com.xieguiawu.rebirth.yml`

```yaml
# 类别必须取自官方 config/categories.yml（2026-09 实测：无通用 "Games"，
# 已拆分为细分游戏类别；本作 = 文字人生模拟 + roguelike 重开循环 → Role-Playing Game）
# 2026-09-25 起与 docs/fdroid/com.xieguiawu.rebirth.yml 及 fdroiddata MR 分支逐字一致。
AntiFeatures:
  NonFreeNet:
    en-US: Optional AI narration uses proprietary LLM services (DeepSeek, OpenRouter
      or any OpenAI-compatible endpoint). It is disabled by default and the game is
      fully playable offline with zero network requests.
Categories:
  - Role-Playing Game
License: MIT
AuthorName: xieguaiwu
AuthorEmail: xieguaiwu@163.com
SourceCode: https://github.com/xieguaiwu/android-rebirth
IssueTracker: https://github.com/xieguaiwu/android-rebirth/issues
Changelog: https://github.com/xieguaiwu/android-rebirth/releases
Donate: https://github.com/sponsors/xieguaiwu

AutoName: 重生 Rebirth

RepoType: git
Repo: https://github.com/xieguaiwu/android-rebirth

Builds:
  - versionName: 0.10.2
    versionCode: 1002
    commit: 712c549ba1bc4ad6c3771a04a2b7991a1f310ce1
    subdir: app
    gradle:
      - yes
    prebuild: bash ../scripts/fetch-go.sh
    scanignore:
      - .go-cache
    build: bash ../scripts/build-core.sh

# Verified route (self-signed releases, optional): add after first release
# Binaries: https://github.com/xieguaiwu/android-rebirth/releases/download/v%v/rebirth-v%v.apk
# AllowedAPKSigningKeys:
#   - 05dc5079f0b55cce97d564c413c85c249c821435b4cac72d4893a50250bc2ae9

AutoUpdateMode: Version
UpdateCheckMode: Tags
CurrentVersion: 0.10.2
CurrentVersionCode: 1002
```

## MR 描述

```markdown
## Summary
Add Rebirth (com.xieguiawu.rebirth) — an Android client for the rebirth
terminal life-restart simulator, built on a computational-psychiatry model
of traumatic memory.

## Details
- MIT licensed
- NonFreeNet declared: optional AI narration uses proprietary LLM services
  (DeepSeek / OpenRouter / any OpenAI-compatible endpoint); disabled by
  default — the game is fully playable offline with zero network requests
- Text-only with mature themes (trauma, mental illness, sex work, cult
  abuse); no images, no ads, no tracking
- Reproducible build verified at tag v0.10.2 (two clean builds → identical
  unsigned APK SHA-256
  `047ab7be11e6055d3295068c1a46e85c2ee123dbcd714c889f4613823088bdc6`)
- Fastlane metadata (en-US / zh-CN)
- Category Role-Playing Game (validated against config/categories.yml)

## Build
- `subdir: app` (review feedback applied) — the Gradle module lives in
  `app/`; fdroidserver finds the release APK under
  `app/build/outputs/apk/release/`
- `prebuild: bash ../scripts/fetch-go.sh` downloads a pinned Go 1.25.10
  toolchain (SHA-256 verified; fails closed on mismatch; cache anchored to
  the repository root). No NDK needed. The command runs from the `app/`
  subdir, hence the `../scripts/…` paths.
- `build: bash ../scripts/build-core.sh` cross-compiles the pure-Go engine
  for arm64-v8a into `app/src/main/jniLibs/` before Gradle runs
- The app is arm64-v8a only; the deterministic engine runs as an in-app
  child process
- No prebuilt binaries are tracked in the repository
```

## 评审关注点（reviewer 可能问）

- **Go 工具链下载**：`prebuild` 从 go.dev 拉 Go 1.25.10（~150 MB，SHA-256 硬编码、
  不匹配即失败退出）——构建需网络，但下载物有 pin 可交叉核对
- **构建脚本组合**：`gradle: yes` + `build:` 脚本是 fdroidserver 支持的路径
  （`build:` 不覆盖 gradle，两者都跑——已源码级核实）；v0.10.2 起 `subdir: app`
  （reviewer 要求），prebuild/build 从 `app/` 目录运行、路径 `../scripts/…`
  （已端到端复刻验证）。修复记录：构建服务器缺 `file(1)` 导致旧版失败，
  v0.10.2 改为 `od(1)` ELF 魔数校验
- **NonFreeNet**：AI 叙事可选且默认关闭，应用完全可离线玩；full_description 已声明
- **内容分级**：成人向文字主题（创伤/精神疾病/性工作/邪教虐待），无图片；
  fastlane 已含 content advisory
- **类别说明**：官方 categories.yml 已无通用 "Games"，本作 = 文字人生模拟 +
  roguelike 重开循环 → `Role-Playing Game`（与 Shattered Pixel Dungeon 同类别）
- **签名**：当前走 F-Droid 官方签名（Binaries/AllowedAPKSigningKeys 保持注释）。
  若走 Verified 路线（自有 keystore 已就绪，证书 SHA-256
  `05dc5079f0b55cce97d564c413c85c249c821435b4cac72d4893a50250bc2ae9`），
  必须在首次发布前决定，之后不可更换
- **可复现性**：比较 unsigned APK（签名引入逐构建随机性），
  `SOURCE_DATE_EPOCH = tag 提交时间`

## 提交前自检清单

- [ ] **完整真机冒烟**（整局、杀进程恢复、飞行模式离线；exec `.so` 已由真机截图证实可用）
- [x] 真机截图替换 `fastlane/metadata/android/{en-US,zh-CN}/images/phoneScreenshots/`（2026-09-12）
- [x] `git ls-remote --tags origin` 含 v0.10.0 / v0.10.1 / v0.10.2
- [x] `bash scripts/validate-fdroid-metadata.sh docs/fdroid/com.xieguiawu.rebirth.yml` 通过（2026-09-25 复跑）
- [x] MR 描述/文档中的可复现哈希与 v0.10.2 读数一致（`047ab7be…bdc6`）

MR 合并后 24-48 小时出现在 F-Droid 主仓库（签名步骤人工介入）。
