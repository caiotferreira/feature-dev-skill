#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.claude/skills ~/.codex/skills

ln -sf "$REPO_DIR/feature-dev" ~/.claude/skills/feature-dev
ln -sf "$REPO_DIR/feature-dev" ~/.codex/skills/feature-dev

echo "Symlinks criados:"
echo "  ~/.claude/skills/feature-dev -> $REPO_DIR/feature-dev"
echo "  ~/.codex/skills/feature-dev  -> $REPO_DIR/feature-dev"
