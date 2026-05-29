# CLAUDE

本文件约定模型在本仓库中的工作规范。

## 写作风格
- 语言简洁，避免堆砌术语
- 先给结论，再给解释
- 示例尽量最小可运行

## 目录结构
按**主题**组织，每个主题一个顶层目录，内部子目录结构一致：
```
{topic}/
├── lessons/       # AI 讲解内容
├── practice/      # 跟做练习
├── homework/      # 独立作业
├── roadmap/       # 阶段规划与进度
├── prompts/       # 沉淀的提示词
└── resources/     # 收藏资料
```
全局目录（跨主题）：`daily/`（每日记录）、`review/`（复盘）

新建主题时，创建完整子目录结构，空的用 .gitkeep 占位。

## 文件命名
- {topic}/lessons/: 按编号命名，例如 01-overview.md
- {topic}/roadmap/: plan.md 或按阶段命名
- daily/: 使用日期，例如 2026-05-27.md
- review/: 使用周期，例如 2026-W22.md

## 内容优先级
1. roadmap/ 的计划优先于临时想法
2. lessons/ 与 practice/ 要成对出现
3. homework/ 要包含评分点或自评清单

## 禁止事项
- 不要改动用户已有笔记内容
- 不要删除历史记录
- 不要生成与主题无关的长文本
