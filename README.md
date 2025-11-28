# ai-sandbox

Sandboxed container environment for running AI coding assistants (Claude Code, Gemini CLI, OpenAI Codex) with reduced risk.

## Overview

This project provides wrapper scripts that run AI CLI tools inside rootless Podman containers with:

- Dropped capabilities (`--cap-drop=ALL`)
- No privilege escalation (`--security-opt=no-new-privileges`)
- User namespace isolation (`--userns=keep-id`)
- Isolated networking (`--network=slirp4netns`)
- Workspace mounted read-write, config directories mounted appropriately

## Requirements

- Podman (rootless)
- The AI CLI tools require their own API keys/authentication

## Building

```bash
./build.sh
```

This builds the `ai-sandbox:latest` container image with all three AI CLIs pre-installed.

## Usage

Each wrapper script runs its respective AI CLI in a sandboxed container:

```bash
# Run in current directory
./claudebox
./geminibox
./codexbox

# Run in a specific directory
./claudebox /path/to/project
./geminibox /path/to/project
./codexbox /path/to/project
```

## What's Included

| File | Description |
|------|-------------|
| `Containerfile` | Container image definition (Arch Linux base with AI CLIs) |
| `build.sh` | Builds the container image |
| `claudebox` | Wrapper for Claude Code (`claude`) |
| `geminibox` | Wrapper for Gemini CLI (`gemini`) |
| `codexbox` | Wrapper for OpenAI Codex (`codex`) |

## Configuration

Each wrapper mounts the respective CLI's config directory from your home:

- `~/.claude` for claudebox
- `~/.gemini` for geminibox
- `~/.codex` for codexbox

GitHub CLI config (`~/.config/gh`) is mounted read-only for git operations.

## MCP Servers

The container includes the Shopify MCP server (`@shopify/dev-mcp`). The wrapper scripts configure it automatically.

## License

BSD 3-Clause License. See [LICENSE](LICENSE).
