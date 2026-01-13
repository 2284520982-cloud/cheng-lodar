#!/usr/bin/env python3
# 检查payload_x64.bin的内容

with open('payload_x64.bin', 'rb') as f:
    data = f.read()

print(f"[*] Payload大小: {len(data)} bytes")
print(f"[*] 前32字节: {data[:32].hex()}")
print(f"[*] 前32字节 (ASCII): {data[:32]}")

# 检查是否包含IP地址
if b'45.6.3.16' in data:
    print("[+] 找到IP: 45.6.3.16")
elif b'4.11' in data:
    print("[+] 找到IP片段: 4.11")
else:
    print("[-] 未找到明显的IP地址")

# 检查是否是Cobalt Strike beacon
if data[0] == 0xFC:
    print("[+] 起始字节: 0xFC (CLD指令)")
elif data[0] == 0xE9:
    print("[+] 起始字节: 0xE9 (JMP指令)")
else:
    print(f"[?] 起始字节: 0x{data[0]:02X}")

# 检查是否包含常见的shellcode特征
if b'kernel32' in data.lower():
    print("[+] 包含 kernel32 字符串")
if b'ws2_32' in data.lower():
    print("[+] 包含 ws2_32 字符串")
if b'wininet' in data.lower():
    print("[+] 包含 wininet 字符串")

print(f"\n[*] 完整hex dump (前128字节):")
for i in range(0, min(128, len(data)), 16):
    hex_str = ' '.join(f'{b:02x}' for b in data[i:i+16])
    ascii_str = ''.join(chr(b) if 32 <= b < 127 else '.' for b in data[i:i+16])
    print(f"{i:04x}: {hex_str:<48} {ascii_str}")
