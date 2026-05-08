#!/bin/bash

# Get list of all modified, deleted, and untracked files
files=$(git status --short | awk '{print $2}')

for file in $files; do
  if [ -f "$file" ] || [ -d "$file" ]; then
    echo "Committing $file..."
    git add "$file"
    git commit -m "Add/Update $file"
  fi
done

echo "Pushing to GitHub..."
git push origin main
