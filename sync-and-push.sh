#!/usr/bin/env bash
# DebtLedger Pro is a plain native Android project (WebView + WebViewAssetLoader) —
# there is no Capacitor, no npm, no "cap sync" step here. All this script does is:
#   1. copy your latest single-file HTML into app/src/main/assets/index.html
#   2. commit and push to GitHub
#
# Usage (run from the repo root, the folder containing settings.gradle):
#   bash sync-and-push.sh "commit message here"
#
# Optional env var:
#   SOURCE_HTML=path/to/DebtLedgerPro-with-scanner.html   (default: ./index.html)

set -e

SOURCE_HTML="${SOURCE_HTML:-index.html}"
COMMIT_MSG="${1:-Update DebtLedger Pro assets}"
ASSETS_DIR="app/src/main/assets"

echo "── 1/3: Copying $SOURCE_HTML into $ASSETS_DIR/index.html"
if [ ! -f "$SOURCE_HTML" ]; then
  echo "ERROR: $SOURCE_HTML not found. Set SOURCE_HTML=path/to/your/index.html"
  exit 1
fi
if [ ! -d "$ASSETS_DIR" ]; then
  echo "ERROR: $ASSETS_DIR not found — run this from the repo root (next to settings.gradle)."
  exit 1
fi
cp "$SOURCE_HTML" "$ASSETS_DIR/index.html"

echo "── 2/3: Staging and committing"
git add -A
if git diff --cached --quiet; then
  echo "No changes to commit — skipping commit/push."
  exit 0
fi
git commit -m "$COMMIT_MSG"

echo "── 3/3: Pushing to GitHub"
git push

echo "Done. $ASSETS_DIR/index.html is updated and pushed."
echo "Build the APK from Android Studio (or your GitHub Action) as usual — no separate sync step needed."
