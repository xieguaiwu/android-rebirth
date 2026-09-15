# F-Droid 收录提交指引（重生 Rebirth）

本目录包含提交流程所需的一切。你只需要一个 GitLab 账号，约 2 分钟完成。

> ✅ **已提交**：[MR !48687](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/48687)（2026-09-13），等待审核（排期常 1-4 周）。以下内容保留作记录；fork CI 因新账号身份验证不可用（零 job），本地 `fdroid lint`（2.4.5）exit 0。
>
> 🔄 **审核第一轮已响应**（2026-09-15，reviewer linsui）：MR 描述已换成官方 App Inclusion 模板+勾选框（标题 `New app: Rebirth`）、`commit` 钉全 hash、单 Build、NonFreeNet 补理由、元数据 rewritemeta 规范形；本地已复刻 CI 全套（rewritemeta/lint/checkupdates/tools/**fdroid build 端到端**/scanner）全绿，待维护者重触发上游 CI。本文件的原始提交说明保留作记录；`fdroiddata-mr-0001.patch` 已按当前分支重生成（基于最新上游 master，仍可直接 `git am`）。

> ⚠️ **提交前先读「前置条件」**——本项目是候选中最特殊的一个：还有 P0 真机
> 验证未做，且它是唯一带「下载 Go 工具链」prebuild 步骤的构建。

## 前置条件（当前状态，2026-09-12）

| 条件 | 状态 |
|---|---|
| LICENSE（MIT） | ✅ 仓库根 |
| 依赖全 FOSS（Kotlin/Compose + 纯 Go 核心；无预编译二进制入库） | ✅ Go 工具链由 `prebuild` 下载（SHA-256 pin、fail-closed），核心全量源码构建 |
| Gradle wrapper 已提交 | ✅ |
| git tag `v0.10.1` | ✅ 已打并推送 |
| fastlane 元数据（en-US + zh-CN，changelog 1000/1001） | ✅ |
| 可复现构建验证（unsigned 双构建） | ✅ `dd0570c0…5a11`（tag v0.10.1） |
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
Categories:
  - Role-Playing Game
License: MIT
AuthorName: xieguaiwu
AuthorEmail: xieguaiwu@users.noreply.github.com
SourceCode: https://github.com/xieguaiwu/android-rebirth
IssueTracker: https://github.com/xieguaiwu/android-rebirth/issues
Changelog: https://github.com/xieguaiwu/android-rebirth/releases
Donate: https://github.com/sponsors/xieguaiwu
AutoName: 重生 Rebirth
Summary: Terminal life-restart simulator with a real trauma model
Description: |
  rebirth is a life-restart simulator built on a computational-psychiatry
  model of traumatic memory (leaky-integrator trace, amygdala/prefrontal
  coupling, hysteresis). Optional AI narration uses proprietary LLM
  services (DeepSeek / OpenRouter / any OpenAI-compatible endpoint) and is
  disabled by default — the game is fully playable offline with zero
  network requests. Contains mature text themes (trauma, mental illness,
  sex work, cult abuse), no images.

AntiFeatures:
  - NonFreeNet
RepoType: git
Repo: https://github.com/xieguaiwu/android-rebirth

Builds:
  - versionName: 0.10.0
    versionCode: 1000
    commit: v0.10.0
    gradle:
      - yes
    prebuild:
      - bash scripts/fetch-go.sh
    build:
      - bash scripts/build-core.sh

  - versionName: 0.10.1
    versionCode: 1001
    commit: v0.10.1
    gradle:
      - yes
    prebuild:
      - bash scripts/fetch-go.sh
    build:
      - bash scripts/build-core.sh

# Verified route (self-signed releases, optional): add after first release
# Binaries: https://github.com/xieguaiwu/android-rebirth/releases/download/v%v/rebirth-v%v.apk
# AllowedAPKSigningKeys:
#   - 05dc5079f0b55cce97d564c413c85c249c821435b4cac72d4893a50250bc2ae9

AutoUpdateMode: Version
UpdateCheckMode: Tags
CurrentVersion: 0.10.1
CurrentVersionCode: 1001
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
- Reproducible build verified at tag v0.10.1 (two clean builds → identical
  unsigned APK SHA-256
  `dd0570c03c51593d85e7fea6a202b8baaad45e54ca7467f13982e9d44d6d5a11`)
- Fastlane metadata (en-US / zh-CN)
- Category Role-Playing Game (validated against config/categories.yml)

## Build
- `gradle: yes` at the repo root (no `subdir`; the Gradle project root is
  the repository root)
- `prebuild: bash scripts/fetch-go.sh` downloads a pinned Go 1.25.10
  toolchain (SHA-256 verified; fails closed on mismatch). No NDK needed.
- `build: bash scripts/build-core.sh` cross-compiles the pure-Go engine for
  arm64-v8a into `app/src/main/jniLibs/` before Gradle runs
- The app is arm64-v8a only; the deterministic engine runs as an in-app
  child process
- No prebuilt binaries are tracked in the repository
```

## 评审关注点（reviewer 可能问）

- **Go 工具链下载**：`prebuild` 从 go.dev 拉 Go 1.25.10（~150 MB，SHA-256 硬编码、
  不匹配即失败退出）——构建需网络，但下载物有 pin 可交叉核对
- **构建脚本组合**：`gradle: yes` + `build:` 脚本是 fdroidserver 支持的路径
  （`build:` 不覆盖 gradle，两者都跑——已源码级核实）
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
- [ ] `git ls-remote --tags origin` 含 v0.10.0 / v0.10.1
- [ ] `bash scripts/validate-fdroid-metadata.sh docs/fdroid/com.xieguiawu.rebirth.yml` 通过
- [ ] MR 描述里的可复现哈希与 `scripts/verify-reproducible.sh` 最新读数一致

MR 合并后 24-48 小时出现在 F-Droid 主仓库（签名步骤人工介入）。
