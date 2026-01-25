# Git Worktrees for Python Projects - Research Guide

## Current Project Setup (paddock-app)

### Project Details
- **Location**: `/home/gabriel/projects/paddock-app/`
- **Project Type**: Multi-service Nx monorepo with Python FastAPI backend
- **Python Version**: Python 3.13 (declared in `.python-version`, pyproject.toml requires >=3.12)
- **Package Manager**: Using `pyproject.toml` (PEP 517/518 standard, no poetry/uv lock file)
- **Build System**: hatchling
- **Dependency Management**: Direct in pyproject.toml (49 dependencies in main, 3 dev)
- **Framework**: FastAPI with async support
- **Location**: `apps/api/` subdirectory within monorepo

### Current Environment Setup
```
File: apps/api/.envrc
─────────────────────
source_up
source .venv/bin/activate 2>/dev/null || true
```
Uses direnv to auto-activate virtual environment when entering directory.

### Key Dependencies
- FastAPI, uvicorn, SQLAlchemy, Alembic (database)
- Pydantic, validation, auth (Authlib, JWT, bcrypt)
- Async/queue support (arq, redis)
- AI/ML (anthropic, voyageai, modal, pgvector)
- AWS (boto3, aioboto3)
- Testing (pytest, pytest-asyncio, pytest-cov)
- Code quality (black, ruff, mypy)

---

## Git Worktrees - How They Work

### Core Concepts
**Worktrees share repository history but have separate working directories:**
- Single `.git` file in each worktree pointing to main `.git/` directory
- Each worktree has its own: HEAD, index, working directory, staging area
- Shared: objects database, branches, tags, remotes
- Can check out different branches in different worktrees simultaneously

### Key Features
```bash
# Create a new worktree for a feature branch
git worktree add ../feature-name          # Auto-creates branch "feature-name"
git worktree add ../fix-issue -b fix/123  # Create with specific branch name
git worktree add ../experiment --detach   # Detached HEAD for experiments

# List all worktrees
git worktree list [-v | --porcelain]

# Remove when done
git worktree remove ../feature-name
git worktree remove -f ../abandoned       # Force remove

# Other operations
git worktree lock <path>                  # Prevent pruning (portable media)
git worktree move <path> <new-path>       # Relocate worktree
git worktree prune                        # Clean stale metadata
```

### Advantages
✅ Parallel work on multiple branches without stashing/switching  
✅ Separate build artifacts per worktree  
✅ Each worktree can have own `.venv`  
✅ Cleaner than `git checkout` switching  
✅ Can run tests on multiple branches simultaneously  
✅ No need to rebuild/re-download deps when switching  

### Disadvantages
❌ Each worktree needs own virtual environment (~200MB for Python)  
❌ Shared object database may use more disk for some workflows  
❌ Pre-commit hooks run in each worktree independently  
❌ IDE indexing multiplies with each worktree  

---

## Worktree Location Strategies

### Option 1: Sibling Directory (RECOMMENDED)
```
project/
├── .git/
├── main_branch_files/
├── .venv/
└── .worktrees/
    ├── feature-auth/
    │   └── .venv/
    ├── fix-database/
    │   └── .venv/
    └── experiment-caching/
        └── .venv/
```

**Pros:**
- Clean separation of concerns
- Easy to list and manage worktrees
- Can use symlinks or directory junction
- Simple to clean up

**Cons:**
- Multiple IDE instances needed for parallel work
- Need to `.gitignore` the `.worktrees/` directory

### Option 2: Parent Directory
```
projects/
├── paddock-app/                   (main)
│   ├── .git/
│   └── apps/api/
├── paddock-app-feature-auth/      (worktree)
│   └── apps/api/
└── paddock-app-fix-database/      (worktree)
    └── apps/api/
```

**Pros:**
- More visible at filesystem level
- Can open separate IDE windows
- Clear naming convention

**Cons:**
- Less organized
- Must manage naming carefully
- More cluttered if many worktrees

### Option 3: Detached in project/
```
project/
├── .git/
├── main files
├── .worktrees_metadata/ (git internal)
├── .feature-auth/  (worktree, shared git, separate .venv)
└── .fix-database/  (worktree, shared git, separate .venv)
```

**Pros:**
- Simple naming (.feature-*, .experiment-*, etc.)
- Can hide with dot prefix
- Less directory nesting

**Cons:**
- Harder to find worktrees
- Need to remember naming convention

---

## Virtual Environment Management Per Worktree

### Problem: Can't Share `.venv` Across Worktrees
`.venv` contains symlinks/paths hardcoded to its creation directory:
```
.venv/pyvenv.cfg:
  home = /absolute/path/to/worktree1

.venv/bin/python -> ../../../usr/bin/python3.13
.venv/bin/activate -> /absolute/path/worktree1/bin/activate
```

**Each worktree MUST have its own `.venv`**

### Solution 1: direnv + .envrc (RECOMMENDED)
**Setup:** Create `.envrc` in each worktree

```bash
# File: .venv/.envrc
source_up
layout python python3.13
```

**Why direnv:**
- Auto-activates on `cd` into directory
- Auto-deactivates on `cd` out
- Integrates with shells (bash, zsh, fish)
- Works across worktrees transparently
- Nix-friendly (available in nixpkgs)

**Integration with worktree creation:**
```bash
# When creating worktree, direnv auto-triggers on cd
cd worktree-path
direnv allow          # Approve the .envrc
direnv exec bash      # Run command with env activated
```

### Solution 2: nix + direnv + dream2nix
For NixOS users in this environment:

```nix
# flake.nix
{
  devShells.default = pkgs.mkShell {
    buildInputs = with pkgs; [
      python313
      python313Packages.pip
    ];
  };
}
```

Combined with `.envrc`:
```bash
use flake
```

### Solution 3: pyenv + pyenv-virtualenv
```bash
# Create and auto-activate venv
pyenv virtualenv 3.13 project-name
pyenv local project-name

# In .envrc:
eval "$(pyenv init - bash)"
```

### Solution 4: uv + automatic venv
**Modern alternative** (if migrating to uv):

```bash
# uv automatically creates .venv
uv sync

# .envrc becomes:
source .venv/bin/activate 2>/dev/null || true
```

---

## Workflow: Comprehensive Setup Script

### The `git-worktree-init` Script

This script creates a worktree with automatic venv setup:

```bash
#!/bin/bash
# git-worktree-init - Create git worktree with Python venv

set -e

BRANCH_NAME="${1:-}"
WORKTREE_DIR="${2:-.worktrees}"
PYTHON_VERSION="${3:-3.13}"

if [[ -z "$BRANCH_NAME" ]]; then
    echo "Usage: git-worktree-init <branch-name> [worktree-dir] [python-version]"
    echo "Example: git-worktree-init feature/new-auth .worktrees 3.13"
    exit 1
fi

# Create worktree
WORKTREE_PATH="${WORKTREE_DIR}/${BRANCH_NAME##*/}"
echo "📁 Creating worktree at $WORKTREE_PATH..."
git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH"

# Create venv
echo "🐍 Creating virtual environment..."
cd "$WORKTREE_PATH"
python$PYTHON_VERSION -m venv .venv

# Create .envrc for direnv
echo "⚙️  Setting up direnv..."
cat > .envrc << EOF
source_up
source .venv/bin/activate 2>/dev/null || true
