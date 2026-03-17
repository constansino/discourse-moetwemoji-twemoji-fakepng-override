#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${SOURCE_DIR:-$ROOT_DIR/twemoji}"
DISCOURSE_ROOT="${DISCOURSE_ROOT:-/var/www/discourse}"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Override source directory not found: $SOURCE_DIR" >&2
  exit 1
fi

TARGET_DIR="${TARGET_DIR:-$(DISCOURSE_ROOT="$DISCOURSE_ROOT" ruby <<'RUBY'
root = ENV.fetch("DISCOURSE_ROOT")
pattern = File.join(root, "vendor", "bundle", "ruby", "*", "gems", "discourse-emojis-*", "dist", "emoji", "twemoji")
matches = Dir[pattern].sort
abort("Could not locate discourse-emojis twemoji directory via #{pattern}") if matches.empty?
puts matches.last
RUBY
)}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Target twemoji directory not found: $TARGET_DIR" >&2
  exit 1
fi

BACKUP_DIR="${BACKUP_DIR:-${TARGET_DIR}.__moetwemoji_backup}"
mkdir -p "$BACKUP_DIR"

applied=0
backed_up=0

shopt -s nullglob
for src in "$SOURCE_DIR"/*.png; do
  name="$(basename "$src")"
  dst="$TARGET_DIR/$name"

  if [ -f "$dst" ] && [ ! -f "$BACKUP_DIR/$name" ]; then
    cp -p "$dst" "$BACKUP_DIR/$name"
    backed_up=$((backed_up + 1))
  fi

  cp -f "$src" "$dst"
  applied=$((applied + 1))
done
shopt -u nullglob

echo "Applied $applied override files into $TARGET_DIR"
echo "Created $backed_up new backup files in $BACKUP_DIR"
