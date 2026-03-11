#!/usr/bin/env bash
# generate-images.sh — Generate missing images from image-prompts/*.json
# Usage: ./scripts/generate-images.sh [slug]
#   No args: process all slugs with missing images
#   With slug: process only that slug
#
# Reads:  scripts/state/image-prompts/<slug>.json
# Writes: images/<slug>/<filename>
# Updates: scripts/state/image-finalizer.json (status -> done/error)

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPTS_DIR="$REPO/scripts/state/image-prompts"
STATE_FILE="$REPO/scripts/state/image-finalizer.json"
GENERATE_PY="/home/daming/.openclaw/workspace-blog-writer/skills/nano-banana-2-new/scripts/generate_image.py"

# --- Get API key from OpenClaw config ---
GEMINI_API_KEY=$(node -e "
const fs=require('fs'), vm=require('vm');
const txt=fs.readFileSync('/home/daming/.openclaw/openclaw.json','utf8');
const obj=vm.runInNewContext('('+txt+')');
process.stdout.write(obj.skills.entries['nano-banana-2-new'].apiKey||'');
")

if [[ -z "$GEMINI_API_KEY" ]]; then
  echo "ERROR: GEMINI_API_KEY is empty. Check OpenClaw config." >&2
  exit 1
fi

# --- Determine which slugs to process ---
if [[ $# -ge 1 ]]; then
  SLUGS=("$1")
else
  # All slugs that have a prompt file
  SLUGS=()
  for f in "$PROMPTS_DIR"/*.json; do
    [[ -f "$f" ]] || continue
    SLUGS+=("$(basename "$f" .json)")
  done
fi

if [[ ${#SLUGS[@]} -eq 0 ]]; then
  echo "No prompt files found in $PROMPTS_DIR"
  exit 0
fi

# --- Helper: update status in image-finalizer.json ---
update_state() {
  local slug="$1" status="$2" generated="$3" error="$4"
  local now
  now="$(date +"%Y-%m-%dT%H:%M:%S+09:00")"

  python3 - "$slug" "$status" "$generated" "$error" "$now" "$STATE_FILE" << 'PYEOF'
import json, sys
slug, status, generated, error, now, state_file = sys.argv[1:]
generated = int(generated)

try:
    with open(state_file) as f:
        state = json.load(f)
except FileNotFoundError:
    state = {"posts": {}}

existing = state["posts"].get(slug, {"path": f"content/posts/{slug}.md", "updatedAt": now})
state["posts"][slug] = {
    **existing,
    "status": status,
    "finalizedAt": now if status == "done" else None,
    "images": {"generated": generated},
    "lastError": error if error else None,
}

with open(state_file, "w") as f:
    json.dump(state, f, indent=2)
    f.write("\n")
PYEOF
}

# --- Main loop ---
TOTAL_GENERATED=0
ERRORS=0

for slug in "${SLUGS[@]}"; do
  prompt_file="$PROMPTS_DIR/$slug.json"
  if [[ ! -f "$prompt_file" ]]; then
    echo "[$slug] No prompt file found, skipping."
    continue
  fi

  echo "[$slug] Processing..."
  image_dir="$REPO/images/$slug"
  mkdir -p "$image_dir"

  # Parse the images array from JSON
  count=$(node -e "const d=require('$prompt_file');process.stdout.write(String(d.images.length));")
  generated=0
  failed=0
  last_error=""

  for ((i=0; i<count; i++)); do
    filename=$(node -e "const d=require('$prompt_file');process.stdout.write(d.images[$i].filename);")
    prompt=$(node -e "const d=require('$prompt_file');process.stdout.write(d.images[$i].prompt);")
    outpath="$image_dir/$filename"

    if [[ -f "$outpath" ]]; then
      echo "  [$filename] Already exists, skipping."
      ((generated++)) || true
      continue
    fi

    echo "  [$filename] Generating..."
    if uv run "$GENERATE_PY" \
        --prompt "$prompt" \
        --filename "$outpath" \
        --resolution 1K \
        --api-key "$GEMINI_API_KEY" 2>&1; then
      echo "  [$filename] ✓ Done ($(du -sh "$outpath" | cut -f1))"
      ((generated++)) || true
    else
      echo "  [$filename] ✗ Failed"
      last_error="generate_image.py failed for $filename"
      ((failed++)) || true
    fi
  done

  if [[ $failed -eq 0 ]]; then
    update_state "$slug" "done" "$generated" ""
    echo "[$slug] ✓ All $generated image(s) ready."
    ((TOTAL_GENERATED+=generated)) || true
  else
    update_state "$slug" "error" "$generated" "$last_error"
    echo "[$slug] ✗ $failed image(s) failed."
    ((ERRORS++)) || true
  fi
done

echo ""
echo "Done. Total generated: $TOTAL_GENERATED | Errors: $ERRORS"
[[ $ERRORS -eq 0 ]]
