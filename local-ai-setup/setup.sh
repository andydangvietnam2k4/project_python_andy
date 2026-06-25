#!/usr/bin/env bash
# =====================================================================
#  Local AI Coding Assistant - macOS / Linux Setup
#  Installs Ollama, pulls the models, installs Continue, and wires up
#  the config so VS Code gets free, unlimited, local AI autocomplete+chat.
# =====================================================================
set -e

cyan()  { printf "\n\033[36m==> %s\033[0m\n" "$1"; }
ok()    { printf "\033[32m  [OK] %s\033[0m\n" "$1"; }
warn()  { printf "\033[33m  [!] %s\033[0m\n" "$1"; }

echo -e "\033[35m=== Local AI Coding Assistant Setup (macOS/Linux) ===\033[0m"

# ---------------------------------------------------------------------
# 1. Ensure Ollama is installed
# ---------------------------------------------------------------------
cyan "Checking for Ollama..."
if ! command -v ollama >/dev/null 2>&1; then
    warn "Ollama not found. Installing..."
    curl -fsSL https://ollama.com/install.sh | sh
    ok "Ollama installed."
else
    ok "Ollama already installed."
fi

# Start the server in the background if it isn't already running
if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    warn "Starting Ollama server..."
    (ollama serve >/dev/null 2>&1 &) || true
fi

# ---------------------------------------------------------------------
# 2. Wait for the Ollama service to respond
# ---------------------------------------------------------------------
cyan "Waiting for Ollama service..."
for i in $(seq 1 30); do
    if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
        ok "Ollama is running."
        break
    fi
    sleep 2
done

# ---------------------------------------------------------------------
# 3. Pull the models
# ---------------------------------------------------------------------
for m in "qwen2.5-coder:1.5b" "qwen2.5-coder:7b" "nomic-embed-text"; do
    cyan "Pulling model: $m"
    ollama pull "$m"
    ok "$m ready."
done

# ---------------------------------------------------------------------
# 4. Install the Continue VS Code extension
# ---------------------------------------------------------------------
cyan "Installing Continue VS Code extension..."
if command -v code >/dev/null 2>&1; then
    code --install-extension Continue.continue
    ok "Continue extension installed."
else
    warn "VS Code 'code' command not found. Install Continue manually from the Extensions panel."
fi

# ---------------------------------------------------------------------
# 5. Copy the config into place
# ---------------------------------------------------------------------
cyan "Configuring Continue..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HOME/.continue"
cp "$SCRIPT_DIR/config.yaml" "$HOME/.continue/config.yaml"
ok "Config copied to $HOME/.continue/config.yaml"

# ---------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------
echo -e "\n\033[35m=== Setup complete! ===\033[0m"
echo "Final step: open VS Code, press Ctrl+Shift+P -> 'Reload Window'."
echo "Then start typing for inline suggestions, or press Ctrl+L to chat."
