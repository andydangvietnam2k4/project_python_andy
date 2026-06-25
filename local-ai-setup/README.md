# 🤖 Local AI Coding Assistant (Free, Unlimited, Offline)

Turn VS Code into your own private GitHub Copilot — running **100% locally** on your
machine. No subscription, no API keys, no usage limits, and it works offline.

This is the exact setup I use. Follow the steps below and you'll have:

- **Inline autocomplete** (gray ghost-text like Copilot — press `Tab` to accept)
- **AI chat** inside VS Code (ask about your code, refactor, explain, fix bugs)
- **Codebase-aware search** (the assistant can read your whole project)

Everything runs through your own CPU/GPU. Your code never leaves your computer.

---

## 🧱 What it's built from

| Piece | What it does | Cost |
|-------|--------------|------|
| [Ollama](https://ollama.com) | Runs AI models locally (the engine) | Free |
| [Continue](https://continue.dev) | VS Code extension — inline + chat | Free |
| `qwen2.5-coder:1.5b` | Fast inline autocomplete | Free |
| `qwen2.5-coder:7b` | Code chat & edits | Free |
| `nomic-embed-text` | Codebase search/embeddings | Free |

**Total download: ~7 GB** (one time). Models are **not** stored in this repo —
the setup script downloads them onto your machine.

---

## 💻 Requirements

- **Windows, macOS, or Linux**
- **16 GB RAM recommended** (8 GB works with smaller models — see *Low-RAM* below)
- **~8 GB free disk space**
- [VS Code](https://code.visualstudio.com/) installed
- A GPU is optional — it works on CPU, just slower for the 7b chat model

---

## 🚀 Quick start

### Windows (PowerShell)

```powershell
# 1. Clone this repo
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>/local-ai-setup

# 2. Run the setup script (installs Ollama, pulls models, configures Continue)
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

### macOS / Linux

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>/local-ai-setup
chmod +x setup.sh
./setup.sh
```

### Final step (both platforms)

1. Open VS Code
2. Press `Ctrl+Shift+P` → type **Reload Window** → Enter
3. Click the **Continue** icon in the left sidebar

Done! 🎉

---

## ⌨️ How to use it

| Key | Action |
|-----|--------|
| `Tab` | Accept the gray inline suggestion |
| `Esc` | Dismiss a suggestion |
| `Ctrl+L` | Open chat / send selected code to chat |
| `Ctrl+I` | Edit selected code with a prompt |

In chat you can type `@codebase <question>` to let the AI search your whole project,
or `@file` to reference a specific file.

> ⚠️ The **first** chat message is slow — the 7b model is loading into RAM.
> After that it's faster. Autocomplete (1.5b) is snappy from the start.

---

## 🪶 Low-RAM machines (8 GB)

If the 7b chat model is too heavy, swap it for a smaller one. Edit `config.yaml`
and change the chat model line to:

```yaml
    model: qwen2.5-coder:3b
```

Then run: `ollama pull qwen2.5-coder:3b`

---

## 🧩 Manual install (if the script fails)

```bash
# 1. Install Ollama from https://ollama.com/download
# 2. Pull the models:
ollama pull qwen2.5-coder:1.5b
ollama pull qwen2.5-coder:7b
ollama pull nomic-embed-text

# 3. Install the Continue extension in VS Code:
code --install-extension Continue.continue

# 4. Copy config.yaml from this repo to your Continue config folder:
#    Windows:  %USERPROFILE%\.continue\config.yaml
#    Mac/Linux: ~/.continue/config.yaml
```

---

## ❓ Troubleshooting

- **No gray suggestions?** Make sure Ollama is running (`ollama list` should work),
  then Reload Window in VS Code.
- **Chat says "model not found"?** Run `ollama list` and confirm the model names match
  `config.yaml`.
- **Too slow?** Use a smaller model (see *Low-RAM* above), or close other heavy apps.

---

## 📜 License

MIT — do whatever you want with it. Share it, improve it, make it yours.
