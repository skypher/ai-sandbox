FROM archlinux:base-devel

# Core tools
RUN pacman -Syu --noconfirm \
    git curl ca-certificates nodejs npm python python-pip ripgrep less \
    github-cli traceroute iputils bind podman \
 && pacman -Scc --noconfirm

# Put npm global bins in /usr/local/bin (keeps /usr/bin tidy)
ENV NPM_CONFIG_PREFIX=/usr/local
ENV PATH=/usr/local/bin:$PATH

# AI CLIs + common MCP servers
RUN npm install -g @anthropic-ai/claude-code \
                   @google/gemini-cli \
                   @openai/codex \
                   @shopify/dev-mcp

WORKDIR /workspace
ENTRYPOINT ["/bin/bash"]
