#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"

mkdir -p ~/.claude/skills ~/.codex/skills

SKILLS=(spec break research plan implement)

for skill in "${SKILLS[@]}"; do
  ln -sf "$SKILLS_DIR/feature-dev-$skill" ~/.claude/skills/feature-dev-$skill
  ln -sf "$SKILLS_DIR/feature-dev-$skill" ~/.codex/skills/feature-dev-$skill
done

echo "Symlinks criados:"
for skill in "${SKILLS[@]}"; do
  echo "  ~/.claude/skills/feature-dev-$skill -> $SKILLS_DIR/feature-dev-$skill"
  echo "  ~/.codex/skills/feature-dev-$skill  -> $SKILLS_DIR/feature-dev-$skill"
done
