#!/bin/bash
# GitLab -> GitHub Sync Script
# Synchronisiert alle Aenderungen von GitLab nach GitHub

# Tokens aus Umgebungsvariablen oder .env Datei laden
if [ -f "$HOME/.gitlab-github-tokens" ]; then
    source "$HOME/.gitlab-github-tokens"
fi

if [ -z "$GITLAB_TOKEN" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo "FEHLER: GITLAB_TOKEN und GITHUB_TOKEN müssen gesetzt sein!"
    echo "Erstellen Sie ~/.gitlab-github-tokens mit:"
    echo "  export GITLAB_TOKEN=\"your-gitlab-token\""
    echo "  export GITHUB_TOKEN=\"your-github-token\""
    exit 1
fi

GITLAB_REPO="https://oauth2:${GITLAB_TOKEN}@gitlab.pascalheim.de/serverhype/gitlab-install.git"
GITHUB_REPO="https://serverhype1:${GITHUB_TOKEN}@github.com/serverhype1/gitlab-install.git"

WORK_DIR="/tmp/gitlab-github-sync"
COMMIT_MSG="gitlab syc."

set -e

echo "=== GitLab -> GitHub Sync ==="

# Arbeitsverzeichnis vorbereiten
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# Von GitLab klonen
echo "[1/4] Klone von GitLab..."
git clone "$GITLAB_REPO" "${WORK_DIR}/repo"
cd "${WORK_DIR}/repo"

# GitHub als zweites Remote hinzufuegen
echo "[2/4] Fuege GitHub Remote hinzu..."
git remote add github "$GITHUB_REPO"

# Auf main Branch pushen
echo "[3/4] Wechsle zum Standard-Branch..."
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||')
git checkout -B main "origin/$DEFAULT_BRANCH"

echo "[4/4] Pushe nach GitHub (main)..."
git commit --allow-empty -m "$COMMIT_MSG"
git push github main --force

# Aufraeumen
rm -rf "$WORK_DIR"

echo ""
echo "=== Sync abgeschlossen! ==="
