# CodeGraph 入门：基本概念与核心能力

## 1. 基本信息

- 名称：CodeGraph
- 官网：[https://colbymchenry.github.io/codegraph/](https://colbymchenry.github.io/codegraph/)
- GitHub：[https://github.com/colbymchenry/codegraph](https://github.com/colbymchenry/codegraph)
- 最新版本：v0.9.7（2026-05-28 发布）
- Star 数：32,178+
- 许可证：MIT
- 主要语言/生态：TypeScript，通过 npm 分发（`@colbymchenry/codegraph`），内置 Node.js 运行时

## 2. 一句话定位

CodeGraph 是一个本地优先的代码知识图谱工具，专为 AI 编程助手（Claude Code、Cursor、Codex 等）设计，让 AI 代理能像查数据库一样理解你的代码结构，而不是一行行扫描文件。

## 3. 前置知识

- **必须掌握**：
  - 命令行基础操作（cd、curl、npm/npx）
  - MCP（Model Context Protocol）概念 —— 知道它是一种让 AI 工具调用外部服务的协议
  - 基本的 AI 编码助手使用经验（Claude Code、Cursor 或类似工具）
- **了解即可**：
  - 图数据库的基本概念（节点、边）
  - tree-sitter（代码解析器）
  - 调用图/依赖图的概念

## 4. 解决什么问题

- **痛点**：AI 编码助手（如 Claude Code）在探索陌生代码库时，会大量使用 grep、glob、Read 等工具逐文件扫描。每次探索都消耗大量 token 和时间 —— 在大型项目中，一次架构问题的回答可能需要数十次工具调用、上百万 token。
- **解法**：CodeGraph 在本地为代码库建立一张语义知识图谱（符号关系、调用链、代码结构）。AI 代理直接查询图谱，一次调用就能拿到入口点、相关符号和代码片段，无需扫描文件。实测平均节省 18% 成本、51% token、57% 工具调用。

## 5. 心智模型锚点

- **它类似于 ctags（代码符号索引），但区别在于**：ctags 只建了一个扁平的符号-位置映射表，而 CodeGraph 建的是带关系的图数据库，能回答"谁调了这个函数"、"从 A 到 B 的调用路径是什么"这类问题。
- **它类似于 Sourcegraph（代码搜索平台），但区别在于**：Sourcegraph 是面向企业级多仓库的服务器端平台，而 CodeGraph 是纯本地、单项目、零配置的轻量工具，专为 AI 代理优化。
- **它类似于 LSP（语言服务协议）的 Go to Definition，但区别在于**：LSP 只能回答单点跳转问题，而 CodeGraph 能做全局的影响分析、调用链追踪和语义上下文构建。

## 6. 优势

- **大幅减少 AI 代理的 token 消耗**：在 VS Code 项目（~10k 文件）上，一次架构问答从 1.81M token 降到 672K，成本从 $0.89 降到 $0.66。场景：你每天用 Claude Code 处理多个项目，一个月下来能省不少 API 费用。
- **支持 20+ 种语言自动索引**：TypeScript、Python、Rust、Go、Java、Swift 等，无需配置。场景：你的项目是 TypeScript 后端 + Swift iOS 前端，CodeGraph 能同时索引并跨语言桥接。
- **自动同步，零配置**：基于文件系统事件（FSEvents/inotify）实时监听，编辑后 2 秒内自动更新图谱。场景：你写完代码保存后，AI 立刻就能查到最新的代码结构。
- **100% 本地运行**：所有数据存在本地 SQLite 中，代码不离开你的机器。场景：你在处理公司私有项目，代码不能上传到任何外部服务。
- **框架感知路由**：自动识别 Django、Express、Spring、Rails 等 14 种 Web 框架的路由文件。场景：你问"哪些 URL 会走到 UserController"，CodeGraph 能直接回答。

## 7. 劣势与边界

- **不适合多仓库全局搜索**：如果你需要在几十个仓库间搜索符号，Sourcegraph 更合适。CodeGraph 是单项目级别的工具。
- **小项目性价比有限**：在 <500 文件的项目上，CodeGraph 的成本优势不明显，有时甚至略贵（因为图谱查询本身也消耗 token）。
- **动态语言支持有局限**：对于 Python 的运行时动态特性（如反射、动态加载），静态分析无法完全覆盖。

**与同类工具对比**：
| 场景 | 推荐工具 |
|---|---|
| AI 编码助手的本地代码理解 | CodeGraph |
| 企业级多仓库代码搜索 | Sourcegraph |
| 轻量级个人代码导航（vim/emacs） | ctags / LSP |

## 8. 安装与验证

**前置依赖**：无（CodeGraph 自带 Node.js 运行时）。如果选择 npm 方式，需要 Node.js。

**macOS / Linux**（推荐）：
```bash
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
```

**已有 Node.js 的用户**：
```bash
npx @colbymchenry/codegraph        # 零安装直接运行
# 或
npm i -g @colbymchenry/codegraph   # 全局安装
```

**Windows（PowerShell）**：
```powershell
irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex
```

**验证安装成功**：
```bash
codegraph --version
# 应输出类似：v0.9.7
```

## 9. 核心概念

- **知识图谱（Knowledge Graph）**：CodeGraph 将代码库中的函数、类、模块等抽象为"节点"，将它们之间的调用、导入、继承关系抽象为"边"，整张图谱存储在本地 SQLite 数据库中。查询图谱就是在这张图上做图遍历。
- **MCP 工具（MCP Tools）**：CodeGraph 作为 MCP 服务器运行时，暴露 10 个工具供 AI 代理调用，包括 `codegraph_search`（按名称搜索符号）、`codegraph_context`（构建代码上下文）、`codegraph_trace`（追踪调用路径）、`codegraph_callers`/`codegraph_callees`（调用者/被调用者）等。
- **自动同步（Auto-Sync）**：CodeGraph 使用操作系统原生文件事件（macOS 的 FSEvents、Linux 的 inotify、Windows 的 ReadDirectoryChangesW）监听代码变动，编辑后经过 2 秒防抖自动增量更新图谱。在同步间隙，工具响应会附带"待同步"警告提示 AI 直接读取文件。
- **框架感知（Framework-Aware Routes）**：CodeGraph 能识别 14 种 Web 框架的路由定义文件，将 URL 模式与处理器函数/类建立连接。例如在 Django 中识别 `urls.py` 里的 `path()`，在 Express 中识别 `app.get()`。
- **CLI vs MCP**：CodeGraph 有两种工作模式。CLI 模式通过命令行手动操作（`codegraph init`、`codegraph query` 等），MCP 模式作为服务器运行（`codegraph serve --mcp`），由 AI 代理自动调用。

## 10. 常见坑

- **坑：安装后没有初始化项目就直接用**
  - **现象**：AI 代理调用 CodeGraph 工具时返回空结果或报错，因为 `.codegraph/` 目录不存在。
  - **解法**：安装后必须先在目标项目运行 `codegraph init -i` 建立索引，再重启 AI 代理。

- **坑：node_modules 等依赖目录被意外索引**
  - **现象**：索引极慢、搜索结果被第三方库淹没。
  - **解法**：CodeGraph 默认排除 `node_modules`、`dist` 等目录并遵循 `.gitignore`。如果你的项目没有 `.gitignore`，确保这些目录名是标准的，或手动添加到 `.gitignore` 中。

- **坑：编辑代码后立即查询，结果仍是旧的**
  - **现象**：刚修改的函数查不到最新内容。
  - **解法**：CodeGraph 有约 2 秒的防抖窗口。等待几秒后自动同步，或手动运行 `codegraph sync`。在同步期间，CodeGraph 会在响应中标注"待同步"文件，AI 会自动读取文件获取最新内容。

- **坑：MCP 配置冲突导致服务器无法启动**
  - **现象**：AI 代理无法连接 CodeGraph，或报错"database is locked"。
  - **解法**：确认 MCP 配置中命令为 `codegraph serve --mcp`。如果是旧版本（<0.9），重新安装。如果是网络文件系统（NAS、WSL2 /mnt），将 `.codegraph/` 移到本地磁盘以启用 WAL 模式。

- **坑：在一个项目中安装了 CodeGraph，换项目后忘记重新索引**
  - **现象**：新项目中 AI 代理不使用 CodeGraph 或返回旧项目的结果。
  - **解法**：全局安装只需一次，但每个项目都需要独立运行 `codegraph init -i` 来创建自己的 `.codegraph/` 索引。

## 11. 下一步

**推荐学习顺序**：

1. **安装并体验**：在本机安装 CodeGraph，在你的项目中运行 `codegraph init -i`，然后用 Claude Code 或 Cursor 体验代码查询。
2. **理解 MCP 工具**：逐个学习 10 个 MCP 工具的用途和返回格式，知道什么时候用 `codegraph_context`、什么时候用 `codegraph_trace`。
3. **框架感知与跨语言**：如果你有 Web 项目或混合语言项目，测试路由识别和跨语言桥接功能。
4. **CLI 深入使用**：学习 `codegraph query`、`codegraph affected` 等 CLI 命令，用于 CI 流程和自动化脚本。
5. **作为库集成**：如果你是工具开发者，学习 `import CodeGraph from '@colbymchenry/codegraph'` 的 API。

**推荐资源**：
- 官方文档：[https://colbymchenry.github.io/codegraph/](https://colbymchenry.github.io/codegraph/)
- 仓库 README 中的 Benchmark 章节（理解性能数据和方法论）
- `src/mcp/server-instructions.ts`（MCP 服务器指令的单一事实来源）
- Reddit 讨论：[r/mcp - CodeGraph: Deterministic architecture analysis](https://www.reddit.com/r/mcp/comments/1qfu3hj/codegraph_deterministic_architecture_analysis_for/)
