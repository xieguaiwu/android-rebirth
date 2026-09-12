# CONTEXT_FOR_NEXT_AGENT.md

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
- [ ] 用户需注册 GitLab 账号（2026-09-06 核查：gitlab.com 查无 xieguaiwu 用户，
      fdroiddata 无任何相关 MR/issue）——五个 app 全部卡在同一个前置条件
- [ ] CLI 仓库 rebirth：android/ 子目录已移除（v0.10.0 tag 含旧 android/，历史遗留）

## 知识图谱

- graphify-out/: 本地可 `graphify update .` 重建（已 gitignore）
- 最后更新: 2026-09-09（安全批+主题批后）

## 最后更新时间

2026-09-13（MR !48687 已提交；fdroid lint 本地通过）
