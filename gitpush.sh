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
GITLAB_BRANCH="clean-gitpush-script"

set -e

echo "=== GitLab -> GitHub Sync ==="

# Schritt 1: Lokale Aenderungen zu GitLab pushen
echo "[1/3] Pruefe lokale Aenderungen..."
if [[ -n $(git status -s) ]]; then
    echo "Aenderungen gefunden - committe zu GitLab..."
    git add -A
    git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin "$GITLAB_BRANCH"
else
    echo "Keine lokalen Aenderungen"
fi

# Schritt 2: Von GitLab zu GitHub synchronisieren
echo "[2/3] Synchronisiere von GitLab zu GitHub..."
WORK_DIR="/tmp/gitlab-github-sync-$$"
rm -rf "$WORK_DIR"
git clone "$GITLAB_REPO" "${WORK_DIR}"
cd "${WORK_DIR}"

# GitHub als zweites Remote hinzufuegen
git remote add github "$GITHUB_REPO"

# Zum sauberen Branch wechseln und zu GitHub pushen
git checkout "$GITLAB_BRANCH"
echo "[3/3] Pushe nach GitHub (main)..."
git push github "${GITLAB_BRANCH}:main" --force

# Aufraeumen
cd - > /dev/null
rm -rf "$WORK_DIR"

echo ""
echo "=== Sync abgeschlossen! ==="
