# =====================================================================
#  Local AI Coding Assistant - Windows Setup
#  Installs Ollama, pulls the models, installs Continue, and wires up
#  the config so VS Code gets free, unlimited, local AI autocomplete+chat.
# =====================================================================

$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  [!] $msg" -ForegroundColor Yellow }

Write-Host "=== Local AI Coding Assistant Setup (Windows) ===" -ForegroundColor Magenta

# ---------------------------------------------------------------------
# 1. Ensure Ollama is installed
# ---------------------------------------------------------------------
Write-Step "Checking for Ollama..."
$ollamaExe = "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe"
if (-not (Get-Command ollama -ErrorAction SilentlyContinue) -and -not (Test-Path $ollamaExe)) {
    Write-Warn "Ollama not found. Downloading installer..."
    $installer = "$env:TEMP\OllamaSetup.exe"
    Invoke-WebRequest -Uri "https://ollama.com/download/OllamaSetup.exe" -OutFile $installer -UseBasicParsing
    Write-Warn "Running installer (silent)..."
    Start-Process -FilePath $installer -ArgumentList "/VERYSILENT","/SUPPRESSMSGBOXES","/NORESTART" -Wait
    Start-Sleep -Seconds 5
    Write-OK "Ollama installed."
} else {
    Write-OK "Ollama already installed."
}

# Make sure ollama is on PATH for this session
if (Test-Path $ollamaExe) { $env:Path += ";$env:LOCALAPPDATA\Programs\Ollama" }

# ---------------------------------------------------------------------
# 2. Wait for the Ollama service to respond
# ---------------------------------------------------------------------
Write-Step "Waiting for Ollama service..."
$ready = $false
for ($i = 0; $i -lt 30; $i++) {
    try {
        Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -UseBasicParsing -TimeoutSec 3 | Out-Null
        $ready = $true; break
    } catch { Start-Sleep -Seconds 2 }
}
if ($ready) { Write-OK "Ollama is running." }
else { Write-Warn "Ollama API not responding yet - it may still be starting. Continuing anyway." }

# ---------------------------------------------------------------------
# 3. Pull the models
# ---------------------------------------------------------------------
$models = @("qwen2.5-coder:1.5b", "qwen2.5-coder:7b", "nomic-embed-text")
foreach ($m in $models) {
    Write-Step "Pulling model: $m"
    ollama pull $m
    Write-OK "$m ready."
}

# ---------------------------------------------------------------------
# 4. Install the Continue VS Code extension
# ---------------------------------------------------------------------
Write-Step "Installing Continue VS Code extension..."
if (Get-Command code -ErrorAction SilentlyContinue) {
    code --install-extension Continue.continue
    Write-OK "Continue extension installed."
} else {
    Write-Warn "VS Code 'code' command not found. Install Continue manually from the Extensions panel."
}

# ---------------------------------------------------------------------
# 5. Copy the config into place
# ---------------------------------------------------------------------
Write-Step "Configuring Continue..."
$continueDir = "$env:USERPROFILE\.continue"
if (-not (Test-Path $continueDir)) { New-Item -ItemType Directory -Path $continueDir | Out-Null }
Copy-Item -Path "$PSScriptRoot\config.yaml" -Destination "$continueDir\config.yaml" -Force
Write-OK "Config copied to $continueDir\config.yaml"

# ---------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------
Write-Host "`n=== Setup complete! ===" -ForegroundColor Magenta
Write-Host "Final step: open VS Code, press Ctrl+Shift+P -> 'Reload Window'."
Write-Host "Then start typing for inline suggestions, or press Ctrl+L to chat."
