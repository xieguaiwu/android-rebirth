# CONTEXT_FOR_NEXT_AGENT.md


> 🔗 跨仓 F-Droid 申请总览（五 app MR 状态 / GitLab 基础设施 / 提交流程 / 教训索引）：`../FDROID_PORTFOLIO.md`——状态变更时与本文双向同步。

最后更新: 2026-09-12（F-Droid 材料补全批）

## 项目当前状态

重生 Rebirth —— 独立安卓仓库（com.xieguaiwu.rebirth），**v0.10.1 已发布**，可构建、全部测试绿。**独立于 CLI 仓库 github.com/xieguaiwu/rebirth**（Go 核心 vendored 在 `core/`，同步上游 @ f7ca787）。

- 仓库: https://github.com/xieguaiwu/android-rebirth（public）
- 本机构建: `./gradlew :app:assembleRelease`（签名需本地 keystore.properties）；
  Go core 变更后 `bash scripts/build-core.sh` + `bash scripts/sync-core.sh`
- **v0.10.1 已发布（2026-09-09）**：tag + GitHub Release + 资产
  `rebirth-v0.10.1.apk`（arm64，9,336,802 B）
  - APK SHA-256 `d9b0b736977c6559fdf9f251534307dbbb8bcec9a751e6a161cf4754f3e4bcd4`
  - 可复现：双构建 unsigned 一致 `dd0570c0...5a11`（SOURCE_DATE_EPOCH=tag 提交）
  - 证书 SHA-256 `05dc5079...bc2ae9` 与 fdroiddata AllowedAPKSigningKeys 一致
  - 上游 rebirth 已 push @ f7ca787（含安全 commit 40673d9），vendored core 同步一致
- 2026-09-09 安全批：Go 层强制 https（防 custom http:// 明文发 key——manifest 策略不覆盖 Go 网络栈）+ redact 补 JSON key 兜底 + 深色主题恒定化；momus 审查超时死亡（600s 零产出），按 §7 降级为自查+测试兜底，**未经独立审查**
- 测试: 27 Robolectric（MainActivity 冒烟 3 / 协议 13 / 语言 5 / Keystore 6）+ vendored core 全量 Go 测试

## 架构

```
app/                      Kotlin/Compose 五屏 + CoreProcess 桥 + Keystore
core/                     vendored Go 引擎（module rebirth）
  cmd/mobile/             JSON-lines daemon（契约 docs/mobile-protocol.md）
  internal/game/          Session 步进器 + 创伤动力学 + 双语数据（data/ data_en/）
  internal/llm/           ChainNarrator 多供应商 failover
  CORE_SOURCE_COMMIT      源 commit（刷新: bash scripts/sync-core.sh）
scripts/
  fetch-go.sh             固定 Go 1.25.10 工具链 + SHA-256 校验
  build-core.sh           arm64 纯 Go 交叉编译 → app/src/main/jniLibs/
  verify-reproducible.sh  双构建 unsigned APK SHA-256 比对
  validate-fdroid-metadata.sh  fdroiddata 草稿校验（类别白名单/tag/changelog）
  sync-core.sh            core/ 从 rebirth 仓库同步
docs/
  mobile-protocol.md      冻结协议契约 v1（与 rebirth 仓库同文）
  fdroid/                 fdroiddata 草稿 + SUBMIT_GUIDE + MR patch（Repo 指向本仓库）
fastlane/                 双语元数据（真机截图 2026-09-12）
```

## 关键事实（勿凭记忆假设）

1. **ABI 只出 arm64-v8a**：Go 1.25 实测 android/amd64、arm、386 全需 cgo → 纯 Go 可复现只剩 arm64。
2. **可复现性比较 unsigned APK**：签名引入逐构建随机性；`-PunsignedRelease` 开关。
3. **checkpoint 重放含 checkpoint 岁**（`<=`）：checkpoint 在 N 岁处理完保存，重放必须处理 0..N 岁，否则 N 岁被处理两次。
4. **resume_session 返回全部重放年份**（`years` 数组）：崩溃丢失的时间线数据只能从这里取回。
5. **多供应商 LLM**：providers 有序 failover，每 provider 独立熔断（连续 3 败），共享预算 24/局（墓志铭免预算）；全关 = 纯离线（Noop）。
6. **key 红线**：key 只经 new_session/resume_session 传入进程内存；checkpoint 不含 key；Go/Kotlin 日志双端脱敏（sk-/nvapi-/bearer 正则）。
7. 双语数据：zh/en 事实键与数字字段零漂移（339 事件脚本验证过）；跨语言 InheritTal 丢失是既定行为。
8. Go 1.25 官方 + Fedora 工具链行为一致（android/amd64 均需 cgo）。

## 待办

- [ ] **真机验证（P0）**：核心风险点已过——真机截图（2026-09-12）显示 app 启动且
      引擎数据正常渲染（出身/天赋页 = exec .so 工作）；完整冒烟（整局/杀进程恢复/
      飞行模式离线/DeepSeek key 叙事）仍待（失败 → 切 gomobile 方案 A）
- [ ] 真机冒烟：完整一局、杀进程恢复、飞行模式离线、DeepSeek key 真机叙事
- [ ] **keystore 离线备份**：~/Desktop/android-projects/rebirth-keystore/（丢失 = 无法更新签名）
- [x] fastlane 截图已换真机实截（2026-09-12，1 张；README docs/screenshots/character-select.png 同步）
- [x] GitHub Release：v0.10.0 已建，资产 `rebirth-v0.10.0.apk`（arm64，9,336,658 B，
      APK SHA-256 `24aa1ae204aa9d3eccb0ce28758ddc3eb942a2de7634ac2836cea2a36075fd83`，
      证书 SHA-256 `05dc5079...bc2ae9` 与 docs/fdroiddata.yml 注释里的
      AllowedAPKSigningKeys 逐位一致）— 2026-09-06
- [x] scripts/fetch-go.sh 改为 **fail-closed**：Go 1.25.10 tarball SHA-256 已硬编码
      （`42d4f7a3...37ba70`，双端点交叉核对 go.dev JSON API + dl.google.com .sha256）；
      未 pin 的版本若无 GO_TARBALL_SHA256 直接 exit 1，不再静默跳过校验 — 2026-09-06
- [x] fdroiddata MR 已提交：**!48687**（2026-09-13，用户确认真机可用后直提）；fork CI 因
      新账号身份验证零 job，本地 `fdroid lint`（2.4.5）exit 0。等审核（1-4 周），
      响应 reviewer 需登录 GitLab 网页
- [ ] 后续真机冒烟补强（整局/杀进程恢复/离线/LLM 叙事）——不阻塞收录，但发现 bug 要发版修
- [x] 用户需注册 GitLab 账号 —— 已完成（xieguaiwu，2026-09-12；五个 app 的 MR 已全部提交，见 FDROID_PORTFOLIO.md）
- [ ] CLI 仓库 rebirth：android/ 子目录已移除（v0.10.0 tag 含旧 android/，历史遗留）

## 知识图谱

- graphify-out/: 本地可 `graphify update .` 重建（已 gitignore）
- 最后更新: 2026-09-09（安全批+主题批后）

## 2026-09-15 F-Droid 审核第一轮响应（reviewer: linsui）

- **reviewer 要求已全部落实**：①MR 描述换 App Inclusion 模板+勾选框，标题改 `New app: Rebirth (com.xieguiawu.rebirth)` ②`commit` 钉全 hash `c0f2a7b52a3a2b632d8026a37c71be8a87c624f9`（tag v0.10.1）③删旧版本 Build（只留 v0.10.1/vc1001）④NonFreeNet 补理由。
- **上游 CI 两项故障已修（元数据侧，应用无改动）**：①`tools check scripts` 失败 = yml 内联 `Summary:` 违规 → 已删 Summary/Description（fastlane en-US/zh-CN 已承载）②`fdroid build` 94 个扫描错 = prebuild 下载的 Go 工具链落在 `.go-cache/` → 加 `scanignore: - .go-cache`（tarball 有 SHA-256 校验，非预编译代码）。
- **本地 fdroid build 端到端复刻又抓出第三个雷（已修）**：本仓 Gradle 根 = 仓库根（无 `subdir`），fdroidserver 默认在 `<root>/build/outputs` 找 APK 而实际在 `app/build/outputs/` → 加 `output: app/build/outputs/apk/release/app-release*.apk`。修后 `fdroid build -l` EXIT=0（扫描→Go→gradle 全链）+ 产物 vc1001/0.10.1 + unsigned 无签名块 + fdroid scanner 零发现。
- **本地 CI 复刻（fdroidserver git master）**：rewritemeta 无 diff / lint 零警告 / checkupdates --auto 无 diff / tools 六脚本全过 / **fdroid build 端到端 EXIT=0** / scanner 零发现。
- fork CI 红叉 = GitLab 身份验证门禁（零 job），已请求 reviewer 从上游重触发。
- 元数据副本 docs/fdroid/*.yml 已同步规范形；validate 脚本已支持全 hash commit。

## 2026-09-25 F-Droid 审核第二轮响应（reviewer: linsui）

**背景**：linsui 09-15 二轮意见挂了 10 天（5 MR 全 `waiting-on-response`）。本轮全量响应。

- **Rebirth 结构（reviewer 要求）**：`subdir: app` + 删 `output`；prebuild/build 改 `bash ../scripts/…`（subdir 下 cwd=app/，已从 fdroidserver 源码核实 + 官方 mastodon 例子佐证）。
- **CI `fdroid build` 红因修复（发 v0.10.2，tag/commit `712c549b…`）**：①构建服务器无 `file(1)` → `build-core.sh` 改 `od(1)` ELF 魔数校验 ②Go 缓存锚定仓库根（`fetch-go.sh` 用脚本位置推导，`subdir` 下 prebuild/build 共享同一缓存，scanignore `.go-cache` 继续有效）③版本 1002/0.10.2 + changelogs 1002（en/zh）+ CHANGELOG 段。
- **5 app 元数据**：联系邮箱 → `xieguaiwu@163.com`（noreply 被点名）；**在与 CI 完全一致的依赖集下重跑 canonical 化**（关键教训：ruamel.yaml 版本影响折行宽度——CI=Debian 0.18.10，本地 PyPI 0.19.1 会假绿；钉 0.18.10 + fdroidserver master a35fddd 后与 CI 期望逐字一致）。
- **本地复刻 CI 全绿**：rewritemeta 幂等 / lint / checkupdates（5/5，无改写）/ schema / fastlane / tools 脚本 / **fdroid build 端到端 EXIT=0**（subdir+../scripts 路径全链：扫描→Go→od 校验→app/ 下 gradle→产物 `app-release-unsigned.apk`）。
- **跨环境可复现性**：fdroid build 产物 SHA-256 与本机 verify-reproducible.sh 读数**逐字节一致**（`047ab7be…bdc6`）。
- GitHub Release v0.10.2 已发（签名资产 `rebirth-v0.10.2.apk`，证书 `05dc5079…bc2ae9`）。
- 上游 CI 已重触发且 **45/45 jobs 全绿**（2026-09-25，fdroid/fdroiddata）——`fdroid build`（subdir 布局 + v0.10.2 修复）与 `rewritemeta` 均通过；已回复绿报 + 勾选描述 pipeline 项。等 reviewer 终审/合并；真机冒烟仍待。

## 最后更新时间

2026-09-25（审核第二轮：subdir 结构 + v0.10.2 构建修复 + 5 app 邮箱/规范形；上游 CI 45/45 全绿）
