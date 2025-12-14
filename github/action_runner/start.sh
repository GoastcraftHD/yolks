#!/bin/bash

# Required environment variables:
# - REPO_URL: GitHub repository URL (e.g., https://github.com/owner/repo)
# - RUNNER_TOKEN: Registration token from GitHub
# Optional:
# - RUNNER_NAME: Custom name for the runner (default: hostname)
# - RUNNER_LABELS: Comma-separated labels (default: self-hosted,Linux,X64)

if [ -z "$REPO_URL" ]; then
    echo "Error: REPO_URL environment variable is required"
    exit 1
fi

if [ -z "$RUNNER_TOKEN" ]; then
    echo "Error: RUNNER_TOKEN environment variable is required"
    exit 1
fi

python3 -m venv .venv 
source .venv/bin/activate
python3 -m pip install --upgrade "pip<23.3"

if ! command -v apt-key >/dev/null 2>&1; then
    echo "Installing apt-key compatibility shim..."

    sudo tee /usr/local/bin/apt-key >/dev/null <<'EOF'
#!/bin/bash
set -e

if [[ "$1" == "add" && "$2" == "-" ]]; then
    mkdir -p /usr/share/keyrings
    gpg --dearmor -o /usr/share/keyrings/legacy-apt-keyring.gpg
    exit 0
fi

echo "apt-key is deprecated; only 'apt-key add -' is supported by this shim" >&2
exit 1
EOF

    sudo chmod +x /usr/local/bin/apt-key
fi

sudo ./bin/installdependencies.sh

RUNNER_NAME=${RUNNER_NAME:-$(hostname)}
RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted,Linux,X64"}

# Configure the runner
./config.sh \
    --url "$REPO_URL" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --unattended \
    --replace

# Cleanup function
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token "$RUNNER_TOKEN"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Start the runner
./run.sh & wait $!
