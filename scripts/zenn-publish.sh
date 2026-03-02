#!/usr/bin/env bash
# zenn-publish.sh
# Checks for untranslated Hugo posts and prints their slugs + content for the agent to translate.
# Usage: bash scripts/zenn-publish.sh [slug]  (no slug = list unpublished)

REPO="/home/daming/workspace/blogs/endrol.github.io"
POSTS_DIR="$REPO/content/posts"
ARTICLES_DIR="$REPO/articles"
PUBLISHED_FILE="$ARTICLES_DIR/.published.json"

if [ ! -f "$PUBLISHED_FILE" ]; then
  echo "{}" > "$PUBLISHED_FILE"
fi

if [ -z "$1" ]; then
  # List posts not yet in .published.json
  echo "=== Unpublished posts ==="
  for f in "$POSTS_DIR"/*.md; do
    slug=$(basename "$f" .md)
    published=$(python3 -c "import json; d=json.load(open('$PUBLISHED_FILE')); print(d.get('$slug',''))" 2>/dev/null)
    if [ -z "$published" ]; then
      echo "$slug"
    fi
  done
else
  # Print content of a specific post for translation
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
