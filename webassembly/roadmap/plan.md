# WebAssembly 学习路线

## 阶段 1：基础认知（已完成）
- [x] 01-overview：基本概念、安装、入门
- [x] 01-demo：最小可运行 Demo（手写 Wasm 二进制，Node.js 加载）

## 阶段 2：理解 WAT 文本格式（推荐优先做）
- 用 `.wat` 文本格式重写 demo 中的函数，用 `wat2wasm` 工具转换为 `.wasm`
- 理解 Wasm 的 section 结构（type、function、export、code）各自的作用
- 尝试在 WAT 中添加线性内存声明 `(memory 1)` 并用 `data` 段写入初始数据

## 阶段 3：Rust → Wasm 实战（主流工具链）
- 安装 `wasm-pack`，用 `wasm-pack new hello-wasm` 创建项目
- 用 `wasm-bindgen` 实现 Rust 函数导出给 JS 调用
- 体验 `wasm-pack build --target web` 和 `--target nodejs` 的区别
- 把 Rust 结构体、字符串传递给 JS，理解 `wasm-bindgen` 如何自动处理内存

## 阶段 4：WASI 与独立运行时（脱离浏览器）
- 安装 Wasmtime（`brew install wasmtime` 或 `curl https://wasmtime.dev/install.sh | bash`）
- 用 Rust 的 `wasm32-wasip1` 目标编译一个读写文件的程序
- 体验 Wasmtime 的权限沙箱（`--dir` 限定可访问目录）
- 了解 WASI Preview 2 和 Component Model 的发展方向

## 阶段 5：前端项目集成 Wasm（实际业务场景）
- 在 Vite 项目中引入 `.wasm`，处理一个真实场景（如图片压缩、Markdown 解析）
- 对比纯 JS 和 Wasm 版本的性能差异，记录数据
- 了解 Wasm 在浏览器中的缓存策略和懒加载方案
