podman build -t ai-sandbox:latest .

# Pre-warm podman's rootless infrastructure (cgroups, namespaces, slirp4netns)
# This takes ~45s on first run after build, but makes subsequent runs instant
echo "Pre-warming container (this may take ~45s)..."
podman run --rm ai-sandbox:latest -c "echo 'Container ready'"
