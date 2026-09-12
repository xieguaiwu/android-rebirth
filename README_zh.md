**English** | [**中文版**](README.md)

# 重生 Rebirth — 安卓人生重开模拟器

[rebirth](https://github.com/xieguaiwu/rebirth) 终端人生重开模拟器的安卓客户端。
确定性 Go 引擎以子进程形式跑在应用内——同种子同人生，与终端版逐字节一致。

```
════ 第 1 代 · 种子 20260823 ════
[出身] 贫民窟 —— 铁皮屋顶下的童年，暴力和匮乏是日常背景音。
[ 13 岁] 摇晃停止后，你在广场上睡了半个月。人离得很近，心也是。
[ 16 岁] ★ 入行：工厂工人 —— 流水线上的日复一日，汗水换温饱。
──── 人生结束：54 岁 · 职业：工厂工人 · 长期抑郁 ────
墓志铭：一生至此。
```

## 特性

- **真实的创伤模型**：漏积分器记忆痕迹 + 杏仁核/前额叶耦合；鞍结分岔 + 迟滞
  （负荷 ≥ 0.80 进入病理态，< 0.35 才退出）；应激敏感性亚加性跨代遗传。
- **中英双语**：UI 与内容双语，应用内一键切换。
- **339 个手写事件**、63 天赋、26 职业、13 出身，AR(1) 确定性运势过程。
- **自带 LLM 密钥**：可配置任意数量供应商（DeepSeek、OpenRouter、任意
  OpenAI 兼容端点），可排序为故障转移链，也可全部关闭纯离线游玩——
  零网络请求。API key 加密存于 Android Keystore，永不离机。
- **抗杀进程**：引擎每年 checkpoint；杀掉应用重开可恢复同一人生（确定性重放）。
- **创伤面板**：M/A/P 动力学实时曲线 + 迟滞带 + 病理吸引子闩锁可视化。
- 隐私：无广告、无追踪、无遥测。唯一权限 INTERNET，仅在开启 AI 叙事时使用。

## 架构

```
┌──────────── Android 应用 com.xieguiawu.rebirth ─────────────────┐
│  Kotlin / Jetpack Compose（五屏：主页/创建/时间线/创伤面板/设置）│
│  CoreProcess 桥：ProcessBuilder exec librebirth_core.so         │
│  JSON-lines 协议（docs/mobile-protocol.md，冻结契约）            │
└──────────────────────────────┬──────────────────────────────────┘
                               │
┌──────────────────────────────┴──────────────────────────────────┐
│  core/ — vendored Go 引擎（module rebirth，源仓库                │
│  github.com/xieguaiwu/rebirth，commit 见 core/CORE_SOURCE_COMMIT）│
│  cmd/mobile: JSON-lines daemon · internal/game: Session 步进器   │
│  internal/llm: 多供应商链（故障转移 + 熔断）                      │
│  data/ + data_en/：双语内容（各 339 事件，embed 编译进二进制）    │
└─────────────────────────────────────────────────────────────────┘
```

## 构建

```bash
# 1. 构建 Go 核心（arm64 纯 Go 交叉编译，约 1 分钟）
bash scripts/build-core.sh          # → app/src/main/jniLibs/arm64-v8a/

# 2. 构建应用
./gradlew :app:assembleRelease      # 仅当存在 keystore.properties 时签名

# 3. 可复现性检查（双构建，比对 unsigned APK）
bash scripts/verify-reproducible.sh
```

依赖：JDK 17+、Android SDK（compileSdk 35）、Go 1.25+（仅第 1 步需要；
F-Droid buildserver 经 `scripts/fetch-go.sh` 拉取固定版本工具链）。

### 刷新 vendored 核心

```bash
bash scripts/sync-core.sh           # 从 ~/Desktop/go-projects/rebirth
bash scripts/sync-core.sh /path/to/rebirth
```

## F-Droid 状态

已准备提交：fastlane 双语元数据、可复现构建实测通过（双构建 unsigned APK
哈希一致）、fdroiddata 草稿在 `docs/fdroid/com.xieguiawu.rebirth.yml`
（已列 v0.10.0 + v0.10.1，类别 Role-Playing Game），提交指引
`docs/fdroid/SUBMIT_GUIDE.md`。已声明反特性：`NonFreeNet`（可选 AI 叙事）。
截图是占位图，待真机实截替换。

## 内容提示

包含成人主题：创伤、精神疾病、性工作、邪教虐待。纯文字虚构内容，面向成年
玩家，无露骨描写。

## 许可

[MIT](LICENSE)
