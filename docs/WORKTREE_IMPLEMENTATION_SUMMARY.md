# Git Worktrees + Python venv Implementation Summary

**Research Date**: January 25, 2026  
**Project**: paddock-app (FastAPI + Nx monorepo)  
**Status**: ✅ Research Complete, Scripts Created

## Executive Summary

Git worktrees enable parallel development on multiple branches with isolated Python virtual environments. This research provides:

1. **Complete understanding** of how git worktrees work
2. **Production-ready scripts** for paddock-app
3. **Integration guide** with direnv for auto-activation
4. **Best practices** and troubleshooting tips

## Project Context

### paddock-app Current Setup
- **Language**: Python 3.13 (PEP 517 pyproject.toml, no poetry/uv)
- **Framework**: FastAPI with async/queue support
- **Dependencies**: 49 core + 3 dev (pytest, ruff, black, mypy)
- **Environment**: Uses direnv with `.envrc` for venv activation
- **Build**: hatchling build backend
- **Tests**: pytest with pytest-asyncio and pytest-cov

### Directory Structure
```
paddock-app/
├── apps/api/          # Main FastAPI app
│   ├── .venv/         # Virtual environment
│   ├── .envrc         # Direnv config (existing)
│   └── pyproject.toml # Dependencies
└── functions/         # Additional Python services
```

## Solution: Git Worktrees + Isolated Venv

### How It Works

**Git Worktrees:**
- Share a single `.git` directory (objects, branches, tags)
- Each worktree has independent HEAD, index, working directory
- Check out different branches simultaneously in different directories

**Per-Worktree Virtual Environments:**
- Each worktree gets its own `.venv` (can't share due to absolute paths)
- Auto-activated via direnv when entering directory
- Full dependency isolation without venv recreation when switching branches

### Directory Structure After Setup

```
paddock-app/
├── .git/                          # Shared repository
├── .gitignore                     # Add: .worktrees/
├── apps/api/
│   ├── .venv/                     # Main worktree venv
│   ├── .envrc                     # Direnv config
│   └── pyproject.toml
├── scripts/
│   ├── git-worktree-init         # Create worktree + venv
│   ├── worktree-utils.sh         # Utility functions
│   ├── .envrc.template           # Template for new worktrees
│   └── tmux-worktree             # Open worktree in tmux
└── .worktrees/                    # Parallel worktrees (gitignored)
    ├── feature-auth/
    │   ├── .venv/                 # Isolated venv
    │   ├── .envrc                 # Auto-activation
    │   └── apps/api/              # Full project copy
    ├── bugfix-database/
    │   └── ...
    └── experiment-caching/
        └── ...
```

## Deliverables

### 1. Research Document
**File**: `docs/GIT_WORKTREES_PYTHON.md` (267 lines)

Complete guide covering:
- Git worktree mechanics and commands
- Venv per-worktree requirements
- Location strategies (sibling, parent, detached)
- Workflow patterns and IDE integration
- Best practices and performance considerations

### 2. Implementation Scripts for paddock-app

#### `scripts/git-worktree-init`
Creates new worktree with automatic setup:
```bash
./scripts/git-worktree-init feature/auth-refactor
```

**Features:**
- ✅ Creates new branch in separate worktree
- ✅ Auto-detects Python 3.13
- ✅ Creates isolated `.venv`
- ✅ Auto-generates `.envrc` for direnv
- ✅ Installs dependencies (including dev extras)
- ✅ Handles monorepo structure (finds `apps/api/pyproject.toml`)

#### `scripts/worktree-utils.sh`
Convenience functions for daily workflow:
- `wt-list` - List all worktrees with details
- `wt-new <branch>` - Create new worktree
- `wt-cd <name>` - Change to worktree
- `wt-remove <path>` - Remove worktree
- `wt-sync` - Sync with main branch
- `wt-prune` - Clean stale metadata
- `wt-branches` - Show branches by worktree

#### `scripts/tmux-worktree`
Open worktree in tmux for parallel terminal sessions

#### `scripts/.envrc.template`
Template for auto-activation in new worktrees

### 3. Setup Guide
**File**: `paddock-app/WORKTREE_SETUP.md`

Complete user guide with:
- Quick start (2-minute setup)
- Step-by-step usage examples
- Common workflows (features, bugfixes, testing)
- Troubleshooting section
- IDE integration (VSCode, PyCharm)
- Best practices checklist

## Usage Examples

### Create Feature Branch Worktree
```bash
cd paddock-app
./scripts/git-worktree-init feature/new-payment-api

cd .worktrees/new-payment-api
direnv allow
# Venv auto-activated, deps ready to go
pytest tests/
```

### Work on Multiple Branches Simultaneously
```bash
# Main worktree (terminal 1)
cd paddock-app/apps/api
# On master branch, running tests

# Feature worktree (terminal 2)
cd paddock-app/.worktrees/feature-auth
# On feature/auth branch, isolated venv, full deps

# Bugfix worktree (terminal 3)
cd paddock-app/.worktrees/bugfix-db
# On bugfix/database branch, own venv
```

### Utility Functions
```bash
source scripts/worktree-utils.sh

wt-list                          # Show all worktrees
wt-new feature/my-feature        # Create new with full setup
wt-cd auth-refactor              # Quick cd to worktree
wt-sync .worktrees/auth-refactor # Update from main
```

## Technical Details

### What Gets Shared (One Copy)
- `.git/` - All repository history
- `.git/objects/` - Git objects database
- `.git/refs/` - Branch/tag references
- `.git/worktrees/` - Worktree metadata

### What Gets Isolated (Per Worktree)
- `.venv/` - Python packages (200-300 MB)
- `HEAD` - Current branch pointer
- `index` - Staging area
- Working directory - All file changes

### Disk Space Requirements
- Main `.venv`: ~250-300 MB
- Per additional worktree: ~250-300 MB
- Recommendation: Keep ≤3 active worktrees (~1 GB total)

### Performance
- **First worktree creation**: ~2-3 minutes (pip installs deps)
- **Subsequent activations**: instant (cached)
- **Branch switching**: instant (no rebuild needed)
- **Benefit over checkout**: No venv recreation, isolated test environments

## Integration Recommendations

### 1. Update .gitignore
```gitignore
# Add to existing .gitignore in paddock-app root:
.worktrees/
```

### 2. Add to README.md
```markdown
## Development with Git Worktrees

For parallel branch development:

\`\`\`bash
./scripts/git-worktree-init feature/my-feature
cd .worktrees/my-feature
direnv allow
\`\`\`

See [WORKTREE_SETUP.md](./WORKTREE_SETUP.md) for detailed guide.
```

### 3. IDE Configuration (Optional)
Create `.vscode/paddock-app.code-workspace` for multi-folder development

### 4. Shell Integration (Optional)
Add to `.bashrc`/`.zshrc`:
```bash
# Worktree shortcuts
source ~/projects/paddock-app/scripts/worktree-utils.sh
```

## Alternatives Considered

### ❌ Rejected: Shared `.venv` Across Worktrees
- **Problem**: `.venv` has absolute paths hardcoded
- **Why fails**: Each worktree has different absolute path
- **Result**: Import errors and broken venv activation

### ❌ Rejected: Stashing + Switching Branches
- **Problem**: Slow context switching
- **Why fails**: Requires pip reinstall on each switch
- **Result**: No parallelism, inefficient

### ✅ Accepted: Per-Worktree Venv + direnv
- **Pros**: Isolated, auto-activated, instant switching
- **Works**: Each worktree is independent path
- **Result**: True parallelism, efficient development

## Deployment & Next Steps

### Immediate (Ready to Use)
1. ✅ Scripts created in `paddock-app/scripts/`
2. ✅ Documentation ready (`WORKTREE_SETUP.md`)
3. ✅ Zero configuration needed
4. ✅ Works with existing direnv setup

### Short Term (Recommended)
1. Update `.gitignore` to add `.worktrees/`
2. Add worktree reference to README.md
3. Train team on workflow (2-3 examples)
4. Document in CONTRIBUTING.md if applicable

### Long Term (Optional)
1. Create GitHub Actions for parallel testing
2. Add pre-commit hooks per worktree
3. Extend scripts for other Python services
4. Consider uv migration for faster installs

## Success Metrics

After implementation, measure:
- **Development speed**: Time to create feature branch environment (target: <5 min)
- **Parallelism**: Number of developers working on different branches simultaneously
- **Efficiency**: Disk space used per developer (target: <2 GB per 3 worktrees)
- **Adoption**: Percentage of team using worktrees vs checkout-based workflow

## References

### Documentation
- `docs/GIT_WORKTREES_PYTHON.md` - Complete technical reference
- `paddock-app/WORKTREE_SETUP.md` - User quick-start guide
- `paddock-app/scripts/` - Ready-to-use scripts

### External Resources
- [Git Worktree Docs](https://git-scm.com/docs/git-worktree)
- [direnv Project](https://direnv.net/)
- [Python venv Docs](https://docs.python.org/3/library/venv.html)
- [Nx Monorepo Guide](https://nx.dev/docs/shared/guides/monorepos)

## Questions & Support

**Q: Can I share `.venv` across worktrees?**  
A: No. `.venv` contains absolute paths. Each worktree needs its own.

**Q: What if I forget to activate the venv?**  
A: direnv auto-activates on `cd` into worktree. Just run `direnv allow` first.

**Q: How do I switch between worktrees?**  
A: Just `cd` into the worktree directory. Venv auto-activates via direnv.

**Q: What about the API sub-directory in monorepo?**  
A: Scripts auto-detect `apps/api/pyproject.toml` and handle it correctly.

---

**Status**: ✅ Complete  
**Last Updated**: January 25, 2026  
**Author**: Research Agent (Claude)
