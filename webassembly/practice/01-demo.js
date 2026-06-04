// 01-demo.js — 手写 Wasm 模块：实现一个 (a + b) * 2 的函数
// 无需任何工具，Node.js 原生支持，复制即可运行

// ① 定义一个最小 Wasm 模块的二进制字节（等价于 WAT: (module (func (export "addDouble") (param i32 i32) (result i32) local.get 0 local.get 1 i32.add i32.const 2 i32.mul)))
const wasmCode = new Uint8Array([
  0x00,0x61,0x73,0x6d,                     // Magic header: "\0asm"
  0x01,0x00,0x00,0x00,                     // Version: 1
  0x01,0x07,                               // Section 1 (Type): 7 bytes
    0x01,                                   //   1 个类型定义
    0x60,0x02,0x7f,0x7f,0x01,0x7f,        //   func (i32, i32) -> (i32)
  0x03,0x02,                               // Section 3 (Function): 2 bytes
    0x01,0x00,                             //   1 个函数，使用类型 #0
  0x07,0x0d,                               // Section 7 (Export): 13 bytes
    0x01,                                   //   1 个导出
    0x09,0x61,0x64,0x64,0x44,0x6f,0x75,0x62,0x6c,0x65,  //   导出名 "addDouble"
    0x00,0x00,                             //   类型=func, 索引=0
  0x0a,0x0c,                               // Section 10 (Code): 12 bytes
    0x01,                                   //   1 个函数体
    0x0a,                                   //   函数体长度 10 bytes
      0x00,                                 //     0 个局部变量
      0x20,0x00,                            //     local.get 0
      0x20,0x01,                            //     local.get 1
      0x6a,                                 //     i32.add
      0x41,0x02,                            //     i32.const 2
      0x6c,                                 //     i32.mul
      0x0b,                                 //     end
]);

// ② 编译并实例化 Wasm 模块
const { instance } = await WebAssembly.instantiate(wasmCode);

// ③ 调用导出的 Wasm 函数：(3 + 5) * 2 = 16
const result = instance.exports.addDouble(3, 5);
console.log(`(3 + 5) * 2 = ${result}`);  // 预期输出: (3 + 5) * 2 = 16
