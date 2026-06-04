## 1. 基本信息
- 名称：WebAssembly（缩写 Wasm）
- 官网：https://webassembly.org/
- GitHub：https://github.com/WebAssembly
- 最新规范版本：Wasm 2.0（MVP 之后持续演进中）
- Star 数：design 仓库 11.6k / spec 仓库 3.4k（截至 2026-06）
- 许可证：Apache-2.0（设计文档）/ 自定义（规范仓库）
- 主要语言/生态：W3C 标准，由 Bytecode Alliance 推动；可编译的语言包括 Rust、C/C++、Go、AssemblyScript、Zig、.NET 等

## 2. 一句话定位
WebAssembly 是一种可移植的二进制指令格式，让开发者把 C/C++/Rust 等语言编译到浏览器或服务器端，以接近原生的速度运行。

## 3. 前置知识
- **必须掌握**：
  - JavaScript 基础（加载和调用 .wasm 模块全靠 JS API）
  - 命令行操作（编译、运行 wasm 需要终端命令）
- **了解即可**：
  - Rust 或 C/C++（任选一门作为编译到 Wasm 的语言）
  - 浏览器开发者工具（调试 Wasm 时方便查看内存和调用栈）
  - 编译原理基础概念（编译目标、链接器——了解即可）

## 4. 解决什么问题
- **痛点**：
  - 浏览器里只能跑 JavaScript，遇到图像处理、视频编解码、游戏引擎等重计算场景，JS 性能不够。
  - 大量已有 C/C++/Rust 代码库无法在 Web 上复用，必须用 JS 重写。
  - 不同 CPU 架构（x86/ARM）需要分别编译，二进制不通用。
- **解法**：
  - Wasm 是一个**通用的中间编译目标**：你把 C/Rust 等编译成 .wasm，浏览器或独立运行时加载执行。
  - Wasm 字节码是沙箱化的，安全隔离；同时在所有主流浏览器和 Node.js 中通用，一次编译到处跑。

## 5. 心智模型锚点
- **它类似于 JVM 字节码，但区别在于**：JVM 字节码是 Java 专属的运行格式，而 Wasm 是语言中立的——任何能编译到 Wasm 的语言都可以跑在同一虚拟机上。
- **它类似于 Docker 镜像，但区别在于**：Docker 打包的是操作系统级别的隔离环境，Wasm 打包的是计算逻辑本身，启动时间毫秒级，体积可以小到几 KB。

## 6. 优势
1. **接近原生性能**：Wasm 在浏览器中通常能达到原生代码 80%~95% 的速度。例如 Figma 把 C++ 图像引擎编译为 Wasm，在浏览器里流畅编辑大型设计文件。
2. **多语言复用**：已有的 C/C++/Rust 库（如 SQLite、FFmpeg）可以直接编译为 Wasm 在 Web 端运行，无需重写。例如 SQLite 官方 WASM 版让浏览器端拥有了完整的本地数据库。
3. **沙箱安全**：Wasm 运行在沙箱中，默认无法访问文件系统、网络等，宿主必须显式授权。适合在不可信代码场景（如插件系统）中使用。
4. **跨平台通用**：同一份 .wasm 文件可以在浏览器、Node.js、Wasmtime（独立运行时）、边缘计算平台（Cloudflare Workers）中运行。

## 7. 劣势与边界
- **不适合的场景**：
  - 纯 UI / DOM 操作：Wasm 不能直接操作 DOM，必须通过 JS 桥接，频繁的 JS-Wasm 互操作反而比纯 JS 更慢。
  - 轻量脚本：如果只是发个 HTTP 请求或处理 JSON，Wasm 的加载+编译开销不值得。
  - 需要完整系统权限的场景：Wasm 的沙箱虽然安全，但也意味着它不能像原生进程那样直接调用系统 API（除非用 WASI 并显式授权）。
- **同类对比**：
  - **vs JavaScript**：JS 开发效率高、生态全，但重计算慢。Wasm 适合把 JS 中的热点计算抽出来加速，二者互补。
  - **vs Native（原生二进制）**：原生性能最好但不跨平台。Wasm 牺牲少量性能换取跨平台和沙箱安全。

## 8. 安装与验证
WebAssembly 本身是**标准**，不需要安装。你需要的是**工具链**（把语言编译为 Wasm）和**运行时**（执行 Wasm）。

### 前置依赖
- Node.js（已安装即可，所有现代版本都内置 WebAssembly 支持）

### 方案 A：Rust → Wasm（推荐，生态最成熟）
```bash
# 安装 Rust wasm 目标
rustup target add wasm32-unknown-unknown

# 可选：安装 wasm-pack（一键打包 + npm 发布）
cargo install wasm-pack
```

### 方案 B：C/C++ → Wasm（Emscripten）
```bash
# macOS
brew install emscripten
# Linux
# 参考 https://emscripten.org/docs/getting_started/downloads.html
```

### 方案 C：AssemblyScript（TypeScript 子集 → Wasm）
```bash
npm init -y
npm install --save-dev assemblyscript
npx asinit .
```

### 验证安装成功
```bash
# 方案 A 验证
rustup target list | grep wasm32-unknown-unknown  # 应显示 "installed"

# 方案 C 验证
npx asc --version  # 应显示版本号

# 通用验证：Node.js 原生支持 Wasm，运行以下命令
node -e "console.log('Wasm supported:', typeof WebAssembly !== 'undefined')"
# 输出：Wasm supported: true
```

## 9. 核心概念
- **Wasm 模块（Module）**：一个 .wasm 文件就是一个 Wasm 模块，类似于动态链接库（.so/.dll）。它包含函数、内存、导出表等，由宿主环境（浏览器/Node.js）加载。
- **WAT（WebAssembly Text）**：Wasm 二进制的人类可读文本格式。`.wat` 文件用 S-expression 语法编写（类似 Lisp），可以转换成 `.wasm`。适合理解 Wasm 底层结构。
- **线性内存（Linear Memory）**：Wasm 只有一块连续的内存缓冲区，所有数据（字符串、数组、结构体）都在这块内存中布局。JS 通过 `ArrayBuffer` 读写这块内存。
- **WASI（WebAssembly System Interface）**：Wasm 的标准系统接口，提供文件读写、环境变量、时钟等能力。没有 WASI，Wasm 无法访问宿主机资源。
- **JS-Wasm 互操作（Import/Export）**：Wasm 模块可以导出函数给 JS 调用，也可以导入 JS 函数来使用宿主能力。JS 和 Wasm 之间的数据传递只能通过数值类型和线性内存。

## 10. 常见坑
1. **坑：直接用 Wasm 操作 DOM**
   - **现象**：发现 Wasm 里没有 `document.getElementById` 之类的 API，编译报错或运行时空指针。
   - **解法**：Wasm 不能直接操作 DOM。必须在 JS 中写 DOM 操作代码，Wasm 通过导入 JS 函数来间接调用。或者使用框架如 Yew、Leptos 来屏蔽这层。

2. **坑：字符串传递以为可以直接传**
   - **现象**：Wasm 函数参数只有 i32/i64/f32/f64，不能直接传字符串，导致编译错误或乱码。
   - **解法**：字符串需要先写入 Wasm 的线性内存，然后把内存指针（i32 地址）和长度传给 Wasm 函数。推荐使用 `wasm-bindgen`（Rust）或 Emscripten 的胶水代码自动处理。

3. **坑：忘记 await WebAssembly.instantiate**
   - **现象**：`WebAssembly.instantiate()` 返回 Promise，忘记 await 就直接调用 `.instance.exports`，得到 undefined。
   - **解法**：始终用 `async/await` 或 `.then()` 处理 Wasm 加载流程。Node.js 中还可以用 `WebAssembly.compileStreaming` 从文件加载。

4. **坑：wasm32-unknown-unknown 没有 WASI 能力**
   - **现象**：用 `wasm32-unknown-unknown` 编译的 Rust 代码尝试读写文件，编译通过但运行时崩溃。
   - **解法**：需要系统调用的代码应使用 `wasm32-wasi` 目标编译，或者在 JS 端通过 import 注入文件操作能力。

5. **坑：大体积 .wasm 导致首屏加载慢**
   - **现象**：编译出来的 .wasm 文件几十 MB，页面加载超时。
   - **解法**：开启编译优化（`--release`），使用 LTO（链接时优化），按需拆分模块。用 `wasm-opt`（Binaryen 工具）进一步压缩体积。

## 11. 下一步
按优先级排列的学习路线：

1. **手写 WAT + Node.js 加载**（理解底层结构）
   - 用 `.wat` 文本格式写一个简单函数，转换为 `.wasm`，在 Node.js 中加载调用
   - 资源：[MDN WebAssembly 文档](https://developer.mozilla.org/en-US/docs/WebAssembly)

2. **Rust + wasm-pack 完整项目**（实战主流工具链）
   - 用 `wasm-pack new` 创建项目，实现一个 Rust 函数导出给前端 JS 调用
   - 资源：[Rust and WebAssembly Book](https://rustwasm.github.io/docs/book/)

3. **线性内存与字符串传递**（核心难点突破）
   - 理解如何在 JS 和 Wasm 之间传递复杂数据（字符串、数组、结构体）
   - 资源：[wasm-bindgen 文档](https://rustwasm.github.io/wasm-bindgen/)

4. **WASI 独立运行时体验**（脱离浏览器）
   - 用 Wasmtime 运行带文件系统访问的 Wasm 模块，体验 Wasm 作为"通用容器"的能力
   - 资源：[Wasmtime WASI Tutorial](https://github.com/bytecodealliance/wasmtime/blob/master/docs/WASI-tutorial.md)

5. **前端项目集成 Wasm**（实际业务场景）
   - 在 Vite/Webpack 项目中引入 .wasm，处理图片处理、PDF 解析等真实场景
   - 资源：[WebAssembly for Web Developers: Getting Started with Wasm in 2026](https://daily.dev/blog/webassembly-getting-started-wasm-web-developers/)
