# Beads Multi-Repository Strategy

This guide explains how to use Beads across multiple repositories with different requirements.

## Quick Start

**Your current setup:** Auto-initializes Beads in all git repos under `~/projects` and `~/work`

```bash
# After home-manager switch, Beads auto-initializes in all repos
# To use immediately in any repo:
cd ~/projects/any-repo
bd ready  # Check for tasks
```

## Three Modes

### 1. Standard Mode (Default - Recommended for Your Projects)
- `.beads/` **committed to git**
- Tasks shared across machines via git
- Full team collaboration support

**Use when:**
- Your personal projects
- Team projects where you control git
- Want task history in version control

**Setup:** Automatic with auto-init, or `bd init`

### 2. Stealth Mode (Private Planning)
- `.beads/` **gitignored** (local only)
- Tasks never committed
- Personal planning on shared repos

**Use when:**
- Work/client repositories
- Can't modify project git
- Contributing to projects where you don't want task tracking visible

**Setup:** `bd init --stealth`

### 3. Contributor Mode (Separate Planning Repo)
- Tasks stored in `~/.beads-planning/<project>/`
- Project repo stays completely clean
- Multiple forks get separate task spaces

**Use when:**
- Open source contributions
- Forked repositories
- Want to keep planning completely separate from project

**Setup:** `bd init --contributor`

## Current Auto-Init Configuration

Your NixOS config is set to auto-initialize:

```nix
programs.beads = {
  enable = true;
  autoInit = true;
  autoInitPaths = [
    "~/projects"  # Your projects
    "~/work"      # Work projects
  ];
};
```

**What this does:**
- On every `home-manager switch`, scans these directories
- Finds all git repos (max depth 3 subdirectories)
- Runs `bd init` in any repo without `.beads/`
- Skips repos already initialized

## Per-Repo Override

If auto-init creates the wrong mode:

```bash
cd ~/projects/some-repo

# Remove auto-initialized .beads
rm -rf .beads

# Re-initialize in desired mode
bd init --stealth       # For private planning
bd init --contributor   # For separate planning repo
```

## Recommended Strategy

### Your Personal Projects (~/projects)
✅ **Use Standard Mode** (auto-init does this)
- Tasks committed to git
- Sync across machines
- Full history

### Work Projects (~/work)
⚠️ **Convert to Stealth Mode**
```bash
# One-time conversion for work repos
for repo in ~/work/*; do
  cd "$repo"
  if [ -d .git ] && [ -d .beads ]; then
    rm -rf .beads
    bd init --stealth
  fi
done
```

### Open Source Contributions
🔀 **Use Contributor Mode**
```bash
cd ~/projects/nixpkgs
bd init --contributor
# Tasks go to ~/.beads-planning/nixpkgs/
# Your fork stays clean
```

## Multi-Machine Sync

### Standard Mode (Your Projects)
Tasks sync automatically via git:
```bash
# Machine 1
bd create "Feature: Add API" -p 0
git add .beads/issues/
git commit -m "Add API task"
git push

# Machine 2
git pull
bd ready  # Task appears automatically
```

### Stealth Mode (Work Projects)
Export/import manually:
```bash
# Machine 1
bd export > tasks.json

# Transfer to Machine 2, then:
bd import tasks.json
```

## Decision Tree

```
Do you control the git repository?
├─ YES → Is it a team project?
│        ├─ YES → Standard Mode (commit .beads/)
│        └─ NO → Standard Mode (your projects)
│
└─ NO → Are you contributing (fork/PR)?
         ├─ YES → Contributor Mode (keep repo clean)
         └─ NO → Stealth Mode (work/client repos)
```

## Common Scenarios

### Scenario 1: Your NixOS Config (This Repo)
```bash
cd ~/projects/system
# Already initialized (auto-init)
bd create "Feature: Add new module" -p 0
git add .beads/
git commit -m "Add task"
```
**Mode:** Standard ✅

### Scenario 2: Work Project
```bash
cd ~/work/client-app
# Auto-initialized, but convert to stealth
rm -rf .beads
bd init --stealth
bd create "Fix: Login bug" -p 0
# Never shows in git status
```
**Mode:** Stealth ✅

### Scenario 3: Open Source PR
```bash
cd ~/projects/beads
git clone https://github.com/steveyegge/beads
bd init --contributor
bd create "PR: Fix issue #123" -p 0
# Tasks in ~/.beads-planning/beads/
# Your fork stays pristine
```
**Mode:** Contributor ✅

## Verification Commands

```bash
# Check current mode
cd ~/projects/some-repo

# Is Beads initialized?
[ -d .beads ] && echo "Initialized" || echo "Not initialized"

# What mode?
if [ -L .beads ]; then
  echo "Contributor mode"
elif git check-ignore .beads &>/dev/null; then
  echo "Stealth mode"
elif [ -d .beads ]; then
  echo "Standard mode"
fi

# Show tasks
bd ready
```

## Best Practices

1. ✅ **Default to standard mode** for personal projects (auto-init handles this)
2. ✅ **Use stealth for work repos** to avoid polluting client git
3. ✅ **Use contributor for OSS** to keep PRs clean
4. ✅ **Commit .beads/issues/** regularly in standard mode
5. ✅ **Document mode in project README** for team coordination
6. ✅ **Export tasks before deleting repos** (all modes)

## Quick Reference

| Command | Purpose |
|---------|---------|
| `bd init` | Standard mode (commits to git) |
| `bd init --stealth` | Stealth mode (gitignored) |
| `bd init --contributor` | Contributor mode (separate repo) |
| `bd ready` | List available tasks |
| `bd export > file.json` | Export tasks (backup/transfer) |
| `bd import file.json` | Import tasks |

## Agent Considerations

Agents automatically detect Beads when working in any repo:
- Check for `.beads/` directory
- Use `bd ready` to find work
- Create tasks with `bd create`
- Update progress with `bd update`
- Complete with `bd done`

The mode is transparent to agents - they use the same commands regardless.

---

**Summary:** Auto-init handles most cases. Override with `bd init --stealth` for work repos or `bd init --contributor` for open source contributions.
