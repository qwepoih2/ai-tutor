#!/bin/bash
# RTK (Rust Token Killer) 入门 Demo
# 演示 RTK 如何压缩常见命令的输出，减少 token 消耗

# ========== 1. 验证安装 ==========
rtk --version                          # 确认 RTK 已安装，显示版本号

# ========== 2. 文件操作对比 ==========
# 不用 RTK：ls -la 输出每行包含权限、所有者、大小、日期等详细信息
ls -la .                               # 原始输出，token 多
# 用 RTK：压缩为树形结构，只显示目录和文件名
rtk ls .                               # 压缩输出，token 少约 80%

# ========== 3. Git 操作对比 ==========
# 不用 RTK：git status 输出包含完整的文件变更列表和提示信息
git status                             # 原始输出，约 300 tokens
# 用 RTK：压缩为精简状态
rtk git status                         # 压缩输出，约 60 tokens

# 不用 RTK：git log 每行显示 commit hash、作者、日期、完整 message
git log -n 5                           # 原始输出，5 个 commit 约 500 tokens
# 用 RTK：每个 commit 压缩为一行
rtk git log -n 5                       # 压缩输出，约 100 tokens

# ========== 4. 文件读取 ==========
# rtk read 可以智能读取文件，支持不同压缩级别
rtk read Cargo.toml                    # 读取文件内容（标准模式）
rtk read src/main.rs -l aggressive     # 激进模式：只显示函数签名，去掉函数体

# rtk smart：两行启发式代码摘要
rtk smart src/main.rs                  # 快速了解文件用途

# ========== 5. 搜索 ==========
# rtk grep 按文件和目录分组搜索结果
rtk grep "fn main" .                   # 分组显示搜索结果

# ========== 6. 测试输出（最有价值的场景之一）==========
# 不用 RTK：cargo test 通过时输出每行 "test xxx ... ok"
# 用 RTK：只显示失败的测试，通过的测试压缩为一行统计
rtk cargo test                         # 只显示失败测试 + 统计摘要

# 通用测试包装器，适用于任何测试命令
rtk test pytest                        # pytest 只保留失败用例（-90%）
rtk test go test ./...                 # go test 只保留失败用例（-90%）

# ========== 7. Docker ==========
rtk docker ps                          # 压缩容器列表
rtk docker images                      # 压缩镜像列表

# ========== 8. 查看你的 token 节省 ==========
rtk gain                               # 查看累计 token 节省统计
rtk gain --history                     # 查看最近的命令历史

# ========== 9. 设置自动拦截（推荐）==========
rtk init -g                            # 安装全局 hook，自动重写命令
# 安装后重启 AI 编程助手，所有 shell 命令自动经过 RTK 压缩
# 例如 AI 执行 "git status" 会被自动重写为 "rtk git status"
