# AGENTS

本文件是给协作/代理使用的操作指南，目标是让 AI 产出的内容可沉淀、可复盘。

## 项目目标
- 让 AI 像导师一样带你系统学习技术
- 产出结构化内容，便于长期复用和复盘

## 目录职责
按**主题**组织，每个主题一个顶层目录（如 `claude/`、`rust/`），内部结构一致：
- `{topic}/roadmap/`: 学习路线与阶段目标
- `{topic}/lessons/`: AI 讲解内容（知识点、原理、示例）
- `{topic}/practice/`: 跟练代码或小项目
- `{topic}/homework/`: 作业题目与解答
- `{topic}/prompts/`: 可复用的提示词模板
- `{topic}/resources/`: 外部资料与简评

全局目录（跨主题）：
- `daily/`: 每日学习记录
- `review/`: 周/月度复盘总结

## 常用流程
1. 读取 `{topic}/roadmap/` 明确学习阶段
2. 生成 `{topic}/lessons/` 讲解内容
3. 生成 `{topic}/practice/` 练习题或小项目
4. 生成 `{topic}/homework/` 独立作业
5. 汇总 `review/` 复盘
6. 记录 `daily/` 当日学习

## 输出格式（建议）
- `{topic}/lessons/`: 标题 + 关键概念 + 最小示例 + 常见误区 + 练习题
- `{topic}/practice/`: 目标 + 约束 + 步骤 + 验收标准
- `{topic}/homework/`: 题目 + 输入/输出 + 评分点 + 自评清单
- `review/`: 本周收获 + 薄弱点 + 下周计划

## 提交规范
- 文件命名遵循 README 中示例
- 同一主题按阶段/编号递增
- 输出后提示用户下一步操作
