# RTK (Rust Token Killer) 入门指南

## 1. 基本信息
- **名称**：RTK（Rust Token Killer）
- **官网**：[https://www.rtk-ai.app/](https://www.rtk-ai.app/)
- **GitHub**：[https://github.com/rtk-ai/rtk](https://github.com/rtk-ai/rtk)
- **最新版本**：v0.42.0（2026-05-24 发布）
- **Star 数**：约 55,800+
- **许可证**：Apache-2.0
- **主要语言/生态**：Rust（单一二进制文件，零依赖）

## 2. 一句话定位
RTK 是一个 CLI 代理工具，坐在 AI 编程助手（如 Claude Code、Copilot、Cursor）和终端之间，通过压缩命令输出来减少 60-90% 的 LLM token 消耗。

## 3. 前置知识
- **必须掌握**：
  - 基本的终端/命令行操作（`ls`、`cat`、`grep`、`git` 等常用命令）
  - 了解什么是 LLM token（AI 模型处理文本的基本单位，token 越多费用越高）
- **了解即可**：
  - AI 编程助手的工作原理（如 Claude Code 通过 Bash 工具执行 shell 命令）
  - Homebrew / Cargo 等包管理器的基本使用

## 4. 解决什么问题
- **痛点**：AI 编程助手在执行 shell 命令时，命令的完整输出会全部塞进 LLM 的上下文窗口。一个 30 分钟的编程会话可能产生约 118,000 个 token 的 shell 输出（如 `ls -la` 的权限信息、`cargo test` 的逐行通过日志、`git push` 的传输细节），其中大部分是对 AI 决策无用的"噪音"。这导致 API 费用高、上下文窗口被快速耗尽。
- **解法**：RTK 作为一个透明代理拦截 shell 命令输出，对每种命令类型应用四种压缩策略（智能过滤、分组聚合、截断保留关键信息、去重），将 ~118,000 token 压缩到 ~23,900 token（-80%），且延迟 <10ms。

## 5. 心智模型锚点
- **锚点 1**：它类似于 **nginx 反向代理**，但区别在于 nginx 代理的是 HTTP 请求，而 RTK 代理的是 CLI 命令的输入输出，专门做"输出压缩"。
- **锚点 2**：它类似于 **图片压缩工具（如 tinypng）**，但区别在于 tinypng 压缩的是图片像素，RTK 压缩的是命令输出文本——去掉注释、空行、重复行、冗余格式，保留 AI 需要的关键信息。

## 6. 优势
1. **显著的 token 节省（60-90%）**：一次 30 分钟会话从 ~118K token 降到 ~24K token，直接省钱。
2. **零配置即用**：安装后运行 `rtk init -g`，hook 自动拦截并重写命令，无需手动修改工作流。
3. **极低延迟（<10ms）**：单个 Rust 二进制文件，压缩处理几乎无感知。
4. **覆盖 100+ 常用命令**：`ls`、`cat`、`grep`、`git`、`cargo test`、`pytest`、`docker`、`kubectl`、`aws` 等主流开发命令都有专门优化。
5. **支持 13 种 AI 编程工具**：Claude Code、Copilot、Cursor、Gemini CLI、Codex、Windsurf、Cline 等都能集成。

## 7. 劣势与边界
1. **不适合需要完整原始输出的场景**：如果你在调试一个需要看到完整日志每一行的 bug，RTK 的压缩可能会遗漏关键细节（不过 `tee` 功能会在命令失败时保存完整输出到文件）。
2. **仅压缩 Bash 工具调用**：Claude Code 内置的 `Read`、`Grep`、`Glob` 工具不经过 Bash hook，不会被 RTK 重写。需要用 shell 命令（`cat`、`rg`、`find`）替代才能享受压缩。
3. **Windows 原生支持有限**：自动重写 hook 需要 Unix shell，原生 Windows 只能用 CLAUDE.md 注入模式或手动调用 `rtk`，推荐用 WSL。

**与同类工具对比**：

| 场景 | 选 RTK | 选其他方案 |
|------|--------|-----------|
| 想要全自动、零工作流改变 | ✅ `rtk init -g` 自动拦截 | — |
| 想精细控制 prompt/context 压缩 | — | 考虑 prompt caching、context window management 方案 |
| 只需减少输出 token（非 CLI） | — | 考虑 "Caveman Claude" 等 prompt 级方案（~75% 输出 token 减少） |

## 8. 安装与验证

### 前置依赖
无（RTK 是单一二进制文件，零依赖）

### macOS（推荐 Homebrew）
```bash
brew install rtk
```

### macOS/Linux（脚本安装）
```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
# 安装到 ~/.local/bin，需要加入 PATH：
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc  # macOS
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # Linux
```

### 通过 Cargo 安装
```bash
cargo install --git https://github.com/rtk-ai/rtk
```
> ⚠️ 注意：crates.io 上有另一个同名 "rtk"（Rust Type Kit），不要用 `cargo install rtk`，必须用 `--git`。

### Windows
从 [releases 页面](https://github.com/rtk-ai/rtk/releases) 下载 `rtk-x86_64-pc-windows-msvc.zip`，解压后将 `rtk.exe` 放入 PATH。推荐用 WSL 获得完整支持。

### 验证安装成功
```bash
rtk --version   # 应显示 "rtk 0.42.0" 或类似版本号
rtk gain        # 应显示 token 节省统计（新安装可能显示暂无数据）
```

## 9. 核心概念
- **CLI Proxy（命令行代理）**：RTK 的核心架构模式。它拦截 AI 助手发出的 shell 命令，执行原命令后对输出做压缩再返回给 AI，类似网络代理但处理的是命令输出流。
- **Auto-Rewrite Hook（自动重写钩子）**：通过 `rtk init -g` 安装的机制，透明地将 `git status` 自动重写为 `rtk git status`，让 AI 助手无需知道 RTK 的存在就能享受压缩。
- **Smart Filtering（智能过滤）**：针对每种命令类型的专用压缩策略。比如 `git push` 只保留 "ok main"，`cargo test` 只保留失败用例，`ls` 用树形结构替代逐行权限信息。
- **Tee（原始输出备份）**：当命令失败时，RTK 将完整未过滤的输出保存到文件（`~/.local/share/rtk/tee/`），让 LLM 可以读取完整日志而不需要重新执行命令。
- **Gain（收益分析）**：`rtk gain` 命令提供的 token 节省统计，支持图表、历史记录、JSON 导出，用于量化 RTK 带来的实际收益。

## 10. 常见坑

### 坑 1：用 `cargo install rtk` 安装了错误的包
- **现象**：`rtk gain` 报错或行为异常，因为 crates.io 上有另一个叫 "rtk"（Rust Type Kit）的包
- **解法**：必须用 `cargo install --git https://github.com/rtk-ai/rtk` 安装，或者用 Homebrew `brew install rtk`

### 坑 2：安装后 Claude Code 没有自动使用 RTK
- **现象**：AI 执行的命令还是原始命令，token 没有减少
- **解法**：安装 hook 后必须**重启 Claude Code**（`rtk init -g` 安装 hook → 完全退出 Claude Code → 重新启动），hook 才会生效

### 坑 3：Claude Code 内置工具不走 RTK
- **现象**：使用 `Read`、`Grep`、`Glob` 等内置工具时，RTK 不拦截，token 依然很多
- **解法**：在需要 RTK 压缩的场景下，改用 shell 命令（`cat`/`head`/`tail` 代替 Read，`rg`/`grep` 代替 Grep，`find` 代替 Glob），或者显式调用 `rtk read`、`rtk grep`、`rtk find`

### 坑 4：Windows 原生环境下 hook 不工作
- **现象**：`rtk init -g` 后命令没有被自动重写
- **解法**：使用 WSL（Windows Subsystem for Linux）获得完整支持，或者在 PowerShell 中手动调用 `rtk git status` 等

### 坑 5：调试时看不到完整输出
- **现象**：命令失败了但 RTK 压缩了错误信息，看不到完整日志
- **解法**：RTK 默认开启 `tee` 功能，失败命令的完整输出会保存到 `~/.local/share/rtk/tee/` 目录。可以用 `cat` 读取对应日志文件查看完整输出

## 11. 下一步

按优先级排列的深入学习方向：

1. **配置自定义过滤规则**：学习 `~/.config/rtk/config.toml` 的完整配置，排除不需要重写的命令、自定义 tee 行为
   - 推荐资源：[Configuration guide](https://www.rtk-ai.app/guide/getting-started/configuration)
2. **收益分析与优化**：深入使用 `rtk gain`、`rtk discover`、`rtk session` 分析你的 token 消耗模式，找到未覆盖的节省机会
   - 推荐资源：README 中的 Token Savings Analytics 章节
3. **理解架构设计**：了解 RTK 内部如何针对不同命令实现过滤策略，为贡献代码做准备
   - 推荐资源：[ARCHITECTURE.md](https://github.com/rtk-ai/rtk/blob/develop/docs/contributing/ARCHITECTURE.md)
4. **编写自定义过滤器**：为 RTK 尚未覆盖的命令编写自己的过滤规则
   - 推荐资源：[CONTRIBUTING.md](https://github.com/rtk-ai/rtk/blob/develop/CONTRIBUTING.md)
5. **多 AI 工具集成**：了解如何在 Cursor、Copilot、Gemini CLI 等不同工具中配置 RTK
   - 推荐资源：[Supported Agents guide](https://www.rtk-ai.app/guide/getting-started/supported-agents)
