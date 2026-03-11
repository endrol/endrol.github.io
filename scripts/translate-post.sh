#!/usr/bin/env bash
# translate-post.sh — Translate a single blog post to Zenn (Japanese) or Juejin (Chinese)
# Usage: bash scripts/translate-post.sh <slug> <zenn|juejin>
#
# Reads:   content/posts/<slug>.md  +  scripts/prompts/translate-<lang>.txt
# Writes:  articles/<slug>.md  (zenn)  |  juejin/<slug>.md  (juejin)
# Updates: articles/.published.json   |  juejin/.published-juejin.json

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <slug> <zenn|juejin>" >&2
  exit 1
fi

SLUG="$1"
LANG="$2"

# --- Resolve paths by language ---
case "$LANG" in
  zenn)
    OUTPUT_FILE="$REPO/articles/$SLUG.md"
    STATE_FILE="$REPO/articles/.published.json"
    PROMPT_FILE="$REPO/scripts/prompts/translate-zenn.txt"
    ;;
  juejin)
    OUTPUT_FILE="$REPO/juejin/$SLUG.md"
    STATE_FILE="$REPO/juejin/.published-juejin.json"
    PROMPT_FILE="$REPO/scripts/prompts/translate-juejin.txt"
    ;;
  *)
    echo "ERROR: lang must be 'zenn' or 'juejin'" >&2
    exit 1
    ;;
esac

SOURCE_FILE="$REPO/content/posts/$SLUG.md"

# --- Validate source exists ---
if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "ERROR: Source post not found: $SOURCE_FILE" >&2
  exit 1
fi

# --- Check if already translated ---
if [[ -f "$OUTPUT_FILE" ]]; then
  # Check state
  existing=$(python3 -c "
import json, sys
try:
    d = json.load(open('$STATE_FILE'))
    v = d.get('$SLUG', '')
    # Not translated if missing or empty
    if not v:
        print('missing')
    else:
        print('exists')
except:
    print('missing')
" 2>/dev/null)
  if [[ "$existing" == "exists" ]]; then
    echo "[$SLUG/$LANG] Already translated, skipping."
    exit 0
  fi
fi

echo "[$SLUG/$LANG] Translating..."

# --- Call Claude for translation ---
prompt="$(cat "$PROMPT_FILE")"
translated=$(cat "$SOURCE_FILE" | claude --print --dangerously-skip-permissions \
  --model claude-haiku-4-5 "$prompt")

if [[ -z "$translated" ]]; then
  echo "ERROR: Translation returned empty output" >&2
  exit 1
fi

# --- Write output ---
mkdir -p "$(dirname "$OUTPUT_FILE")"
echo "$translated" > "$OUTPUT_FILE"
echo "[$SLUG/$LANG] ✓ Written to $(basename "$OUTPUT_FILE")"

# --- Update state ---
now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
python3 - "$SLUG" "$LANG" "$now" "$STATE_FILE" << 'PYEOF'
import json, sys
slug, lang, now, state_file = sys.argv[1:]

try:
    with open(state_file) as f:
        state = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    state = {}

if lang == "zenn":
    state[slug] = now
elif lang == "juejin":
    state[slug] = "translated"

with open(state_file, "w") as f:
    json.dump(state, f, indent=2)
    f.write("\n")

print(f"  State updated: {slug} -> {state[slug]}")
PYEOF
