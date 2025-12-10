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
