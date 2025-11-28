FROM archlinux:base-devel

# Core tools
RUN pacman -Syu --noconfirm \
    git curl ca-certificates nodejs npm python python-pip ripgrep less \
    github-cli traceroute iputils bind podman zerotier-one openssh \
    slirp4netns fuse-overlayfs uidmap \
 && pacman -Scc --noconfirm

# Hint podman that user namespaces are configured (helps rootless-in-container)
ENV _CONTAINERS_USERNS_CONFIGURED=1

# Put npm global bins in /usr/local/bin (keeps /usr/bin tidy)
ENV NPM_CONFIG_PREFIX=/usr/local
ENV PATH=/usr/local/bin:$PATH

# AI CLIs + common MCP servers
RUN npm install -g @anthropic-ai/claude-code \
                   @google/gemini-cli \
                   @openai/codex \
                   @shopify/dev-mcp

# SSH key for GitHub access
COPY ssh/id_ed25519_github /root/.ssh/id_ed25519
RUN chmod 600 /root/.ssh/id_ed25519 \
 && ssh-keyscan github.com >> /root/.ssh/known_hosts 2>/dev/null

WORKDIR /workspace
ENTRYPOINT ["/bin/bash"]
