#!/usr/bin/env bash
# translate-post.sh — Translate one blog post to Japanese for Zenn
# Usage: bash scripts/translate-post.sh <slug> [zenn]
#
# Reads:   content/posts/<slug>.md  +  scripts/prompts/translate-zenn.txt
# Writes:  articles/<slug>.md
# Updates: articles/.published.json

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <slug> [zenn]" >&2
  exit 1
fi

SLUG="$1"
LANG="${2:-zenn}"
if [[ "$LANG" != "zenn" ]]; then
  echo "ERROR: only 'zenn' is supported (Juejin was dropped)" >&2
  exit 1
fi

SOURCE_FILE="$REPO/content/posts/$SLUG.md"
OUTPUT_FILE="$REPO/articles/$SLUG.md"
STATE_FILE="$REPO/articles/.published.json"
PROMPT_FILE="$REPO/scripts/prompts/translate-zenn.txt"

if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "ERROR: Source post not found: $SOURCE_FILE" >&2
  exit 1
fi

# Already translated if the file exists and the state has a non-empty entry for it.
if [[ -f "$OUTPUT_FILE" ]]; then
  existing=$(python3 -c "
import json
try:
    print('exists' if json.load(open('$STATE_FILE')).get('$SLUG') else 'missing')
except Exception:
    print('missing')
")
  if [[ "$existing" == "exists" ]]; then
    echo "[$SLUG] Already translated, skipping."
    exit 0
  fi
fi

echo "[$SLUG] Translating..."

prompt="$(cat "$PROMPT_FILE")"
translated=$(cat "$SOURCE_FILE" | claude --print --dangerously-skip-permissions \
  --model claude-haiku-4-5 "$prompt")

if [[ -z "$translated" ]]; then
  echo "ERROR: Translation returned empty output" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT_FILE")"
echo "$translated" > "$OUTPUT_FILE"
echo "[$SLUG] Written to articles/$SLUG.md"

now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
python3 - "$SLUG" "$now" "$STATE_FILE" << 'PYEOF'
import json, sys
slug, now, state_file = sys.argv[1:]
try:
    with open(state_file) as f:
        state = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    state = {}
state[slug] = now
with open(state_file, "w") as f:
    json.dump(state, f, indent=2)
    f.write("\n")
print(f"  State updated: {slug} -> {now}")
PYEOF
