# AI Tutor

> 用 AI 像导师一样带你系统学习新技术，而不是零散地问答。

---

## 目录结构

按**主题**组织，每个技术方向一个顶层目录，内部结构一致：

```
ai-tutor/
├── .claude/
│   └── commands/           # 自定义命令（如 /learn）
├── claude/                 # 主题：Claude
│   ├── lessons/            # AI 讲解内容
│   ├── practice/           # 跟做练习
│   ├── homework/           # 独立作业
│   ├── roadmap/            # 阶段规划与进度
│   ├── prompts/            # 沉淀的提示词
│   └── resources/          # 收藏资料
├── rtk/                    # 主题：RTK (Rust Token Killer)
│   ├── lessons/
│   ├── practice/
│   └── ...                 # 同上结构
├── daily/                  # 全局：每日学习记录
├── review/                 # 全局：复盘与反思
├── CLAUDE.md               # 项目规范（给 AI 看）
├── AGENTS.md               # AI 协作指南
├── LEARNING_PATH.md        # 学习路径说明
└── README.md               # 本文件（给人看）
```

---

## `/learn` 命令

项目内置了 `/learn` 命令，一行搞定一项新技术的入门：

```
/learn RTK（Rust Token Killer）
```

它会自动：
1. 从 GitHub API + README + 搜索收集信息
2. 生成结构化学习材料（定位、前置知识、核心概念、常见坑等）
3. 逐文件确认后写入 `{topic}/lessons/`、`{topic}/practice/`、`daily/`

命令定义在 `.claude/commands/learn.md`，可随时修改。

---

## 各目录使用指南

以 `{topic}/` 代表任意主题目录（如 `claude/`、`rtk/`）。

| 目录 | 用途 | 命名规则 |
|------|------|----------|
| `{topic}/roadmap/` | 阶段目标、已完成/待完成项 | `plan.md` 或按阶段命名 |
| `{topic}/lessons/` | AI 讲解内容 | `01-overview.md`、`02-borrowing.md` |
| `{topic}/practice/` | 跟练代码或练习 | 按编号命名 |
| `{topic}/homework/` | AI 出题，独立完成后让 AI 批改 | 包含题目 + 解答 + 评分点 |
| `{topic}/prompts/` | 沉淀好用的提示词模板 | 按用途命名 |
| `{topic}/resources/` | 外部资料 + 你的简评 | 按来源命名 |
| `daily/` | 每天一个文件，快速记录 | `2026-05-27.md` |
| `review/` | 定期复盘，指导下阶段学习 | `2026-W22.md` |

---

## 典型学习流程

```
1. /learn {技术名}       → 自动生成入门材料
2. {topic}/roadmap/      → 规划今天要学的内容
3. {topic}/lessons/      → AI 讲解
4. {topic}/practice/     → 跟着做练习
5. {topic}/homework/     → AI 出题，独立完成
6. review/               → 定期复盘，更新 roadmap
7. daily/                → 每天简单记录
```

---

## 快速开始

在 `{topic}/prompts/` 里准备几个常用提示词，例如：

```markdown
# explain-concept.md
你是一位耐心的编程导师。
请用通俗易懂的语言讲解 [概念名]，包括：
1. 它解决了什么问题
2. 核心原理（用类比）
3. 一个最小可运行的例子
4. 常见误区
5. 一个练习题
```

关于如何更好地用 AI 学技术，详见 `claude/lessons/02-how-to-learn-with-ai.md`。
