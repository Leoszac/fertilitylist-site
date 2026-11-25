#!/bin/sh
# Runs on the cPanel server via cron (every 10 min). Pulls the public repo
# Leoszac/fertilitylist-site (built output only) and syncs site/ into public_html.
# No credentials involved.
set -e
REPO="$HOME/fl-deploy"
DEST="$HOME/public_html"
cd "$REPO"
git fetch -q origin main
REMOTE=$(git rev-parse origin/main)
if [ "$(git rev-parse HEAD)" = "$REMOTE" ] && [ "$(cat "$DEST/.fl-deployed" 2>/dev/null)" = "$REMOTE" ]; then
  exit 0
fi
git reset -q --hard origin/main
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete --exclude '.well-known/' --exclude 'cgi-bin/' --exclude '.fl-deployed' site/ "$DEST/"
else
  cp -a site/. "$DEST/"
fi
echo "$REMOTE" > "$DEST/.fl-deployed"
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) deployed $REMOTE"
