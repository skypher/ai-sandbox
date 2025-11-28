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

- Podman (rootless) **or** host mode fallback (see below)
- The AI CLI tools require their own API keys/authentication

### If you must run podman *inside* another container (nested)

Rootless podman needs user namespaces, writable `/proc/sys` for a few sysctls,
and helpers like `slirp4netns`, `fuse-overlayfs`, and `uidmap` available in the
inner image. The `Containerfile` installs those, but the outer container / host
must also allow them. Run the outer container with at least:

```
--privileged \
--device /dev/fuse \
--security-opt seccomp=unconfined --security-opt apparmor=unconfined \
--tmpfs /run --tmpfs /var/run \
-e _CONTAINERS_USERNS_CONFIGURED=1
```

Additionally, the host kernel must permit user namespaces (e.g.
`sysctl user.max_user_namespaces` > 0). Without those, podman-in-podman will fail
with `chroot ... operation not permitted` or `/proc/... ping_group_range` errors.

## Building

```bash
./build.sh
```

This builds the `ai-sandbox:latest` container image with all three AI CLIs pre-installed.

## Usage

Each wrapper script prefers to run in a sandboxed podman container. If podman
is unavailable or blocked (common inside locked-down containers), it falls back
to a host mode that launches the CLI directly with a temporary `$HOME` to avoid
touching your real dotfiles.

```bash
# Run in current directory
./claudebox
./geminibox
./codexbox

# Run in a specific directory
./claudebox /path/to/project
./geminibox /path/to/project
./codexbox /path/to/project

# Force host mode (skip podman attempts)
AI_SANDBOX_MODE=host ./claudebox
```

Notes:
- In host mode, configs/caches are copied into a temp HOME; GitHub CLI config is
  mirrored read-only when present. Isolation is lighter than the podman setup.
- Podman remains the default when it works; failures auto-trigger host fallback
  unless `AI_SANDBOX_MODE=podman` is set explicitly.

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

- `claudebox` mirrors Claude Code settings so logins/themes persist: `~/.claude`, `~/.config/claude`, `~/.config/anthropic/claude`, caches under `~/.cache/{claude,anthropic/claude}`, and data under `~/.local/share/{claude,anthropic/claude}` when present.
- `~/.gemini` for geminibox
- `~/.codex` for codexbox

GitHub CLI config (`~/.config/gh`) is mounted read-only for git operations.

## MCP Servers

The container includes the Shopify MCP server (`@shopify/dev-mcp`). The wrapper scripts configure it automatically.

## License

BSD 3-Clause License. See [LICENSE](LICENSE).
