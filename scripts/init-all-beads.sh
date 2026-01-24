#!/usr/bin/env bash
# Initialize Beads in stealth mode for all git repositories
set -e

SEARCH_PATHS=(
  "$HOME/projects"
  "$HOME/work"
)

echo "🔮 Initializing Beads in stealth mode for all git repositories..."
echo ""

total_repos=0
initialized=0
skipped=0

for base_path in "${SEARCH_PATHS[@]}"; do
  if [ ! -d "$base_path" ]; then
    echo "⚠️  Path not found: $base_path (skipping)"
    continue
  fi
  
  echo "📁 Scanning: $base_path"
  
  # Find all git repositories (max depth 3)
  while IFS= read -r git_dir; do
    repo_dir=$(dirname "$git_dir")
    total_repos=$((total_repos + 1))
    
    cd "$repo_dir"
    repo_name=$(basename "$repo_dir")
    
    if [ -d ".beads" ]; then
      echo "  ⏭️  $repo_name - already initialized (skipped)"
      skipped=$((skipped + 1))
    else
      echo "  🔧 $repo_name - initializing..."
      if bd init 2>/dev/null; then
        initialized=$((initialized + 1))
        echo "     ✅ Success"
      else
        echo "     ❌ Failed to initialize"
      fi
    fi
  done < <(find "$base_path" -maxdepth 3 -type d -name .git 2>/dev/null)
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Summary:"
echo "   Total repositories: $total_repos"
echo "   Newly initialized:  $initialized"
echo "   Already had Beads:  $skipped"
echo ""
echo "🎉 All repositories are now using Beads in stealth mode!"
echo ""
echo "Note: .beads/ directories are gitignored globally."
echo "Tasks are local-only and won't be committed to git."
echo ""
echo "Try it:"
echo "  cd ~/projects/any-repo"
echo "  bd create 'Test task' -p 0"
echo "  bd ready"
