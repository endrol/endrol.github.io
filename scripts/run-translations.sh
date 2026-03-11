#!/usr/bin/env bash
# run-translations.sh — Find and translate all untranslated posts
# Usage: bash scripts/run-translations.sh <zenn|juejin|both>
#
# Finds posts with no entry in the state JSON and translates them one by one.
# Exits non-zero if any translation fails.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POSTS_DIR="$REPO/content/posts"

LANG="${1:-both}"

translate_lang() {
  local lang="$1"
  local state_file

  case "$lang" in
    zenn)    state_file="$REPO/articles/.published.json" ;;
    juejin)  state_file="$REPO/juejin/.published-juejin.json" ;;
    *)       echo "ERROR: unknown lang $lang" >&2; exit 1 ;;
  esac

  # Ensure state file exists
  [[ -f "$state_file" ]] || echo "{}" > "$state_file"

  # Find untranslated slugs
  local slugs=()
  while IFS= read -r slug; do
    slugs+=("$slug")
  done < <(python3 - "$state_file" "$POSTS_DIR" << 'PYEOF'
import json, os, sys
state_file, posts_dir = sys.argv[1], sys.argv[2]

try:
    with open(state_file) as f:
        state = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    state = {}

for fname in sorted(os.listdir(posts_dir)):
    if not fname.endswith(".md"):
        continue
    slug = fname[:-3]
    if slug not in state:
        print(slug)
PYEOF
)

  if [[ ${#slugs[@]} -eq 0 ]]; then
    echo "[$lang] Nothing to translate."
    return 0
  fi

  local count=0
  for slug in "${slugs[@]}"; do
    bash "$REPO/scripts/translate-post.sh" "$slug" "$lang"
    ((count++)) || true
  done

  echo "[$lang] Translated $count post(s)."
}

case "$LANG" in
  both)
    translate_lang zenn
    translate_lang juejin
    ;;
  zenn|juejin)
    translate_lang "$LANG"
    ;;
  *)
    echo "Usage: $0 <zenn|juejin|both>" >&2
    exit 1
    ;;
esac
