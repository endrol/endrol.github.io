#!/usr/bin/env bash
# juejin-publish.sh
# Checks for Hugo posts not yet published to Juejin and prints slugs + content for the agent.
# Usage: bash scripts/juejin-publish.sh [slug]  (no slug = list unpublished)

REPO="/home/daming/workspace/blogs/endrol.github.io"
POSTS_DIR="$REPO/content/posts"
PUBLISHED_FILE="$REPO/juejin/.published-juejin.json"

if [ ! -f "$PUBLISHED_FILE" ]; then
  echo "{}" > "$PUBLISHED_FILE"
fi

if [ -z "$1" ]; then
  echo "=== Unpublished posts (Juejin) ==="
  for f in "$POSTS_DIR"/*.md; do
    slug=$(basename "$f" .md)
    published=$(python3 -c "import json; d=json.load(open('$PUBLISHED_FILE')); print(d.get('$slug',''))" 2>/dev/null)
    if [ -z "$published" ]; then
      echo "$slug"
    fi
  done
else
  slug="$1"
  f="$POSTS_DIR/$slug.md"
  if [ -f "$f" ]; then
    echo "=== SLUG: $slug ==="
    cat "$f"
  else
    echo "ERROR: $f not found"
    exit 1
  fi
fi
