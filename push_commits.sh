#!/bin/bash

# Initialize fresh repo
rm -rf .git
git init
git remote add origin https://github.com/phravins/CRUD-APP.git
git config user.email "you@example.com"
git config user.name "Your Name"

# List files to commit (excluding AGENTS.md and mix.lock)
# Using -not -path '*/.*' to exclude hidden files except if they are explicitly needed?
# Actually the previous find command worked well.
files=$(find . -type f -not -path './.git/*' -not -path './deps/*' -not -path './_build/*' -not -name "AGENTS.md" -not -name "mix.lock" | sort)

count=0
for f in $files; do
  git add "$f"
  git commit -m "Add $(basename "$f")"
  count=$((count+1))
done

echo "Total commits: $count"

# Push
git branch -M main
# We use --force because we've recreated the history
git push -u origin main --force
