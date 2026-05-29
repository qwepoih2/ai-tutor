#!/bin/bash
# CodeGraph 入门 Demo：从零到完成一次代码图谱查询
# 前提：已全局安装 codegraph（运行过 installer 或 npm i -g）

# 1. 进入你的目标项目目录（换成你实际的项目路径）
cd /Users/rr/Desktop/ai-tutor

# 2. 初始化项目并构建图谱（-i 表示同时执行索引）
codegraph init -i

# 3. 验证图谱状态，查看文件数和符号数
codegraph status

# 4. CLI 查询：搜索包含 "init" 的函数/类符号
codegraph query "init" --limit 5

# 5. CLI 查询：查看某个符号的调用者（换成上一步查到的实际符号名）
codegraph callers "init" --limit 3

# 6. CLI 查询：查看某个符号的被调用者
codegraph callees "init" --limit 3

# 7. CLI 查询：分析修改某个符号的影响范围
codegraph impact "init" --depth 2

# 8. 查看项目文件结构
codegraph files --max-depth 2

# 9. 手动同步（如果有新改动）
codegraph sync
