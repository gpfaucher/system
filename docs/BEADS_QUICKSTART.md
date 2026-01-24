# Beads Quick Start

**Stealth mode is configured globally** - all `.beads/` directories are gitignored and stay local to your machine.

## Setup (One-Time)

### 1. Apply NixOS Configuration
```bash
cd ~/projects/system
sudo nixos-rebuild switch --flake .#laptop
```

This installs the `bd` command.

### 2. Initialize All Repositories
```bash
cd ~/projects/system
./scripts/init-all-beads.sh
```

This initializes Beads in all git repos under `~/projects` and `~/work`.

### 3. Verify
```bash
# Check any repo
cd ~/projects/any-repo
bd ready
```

## Using Beads

### Basic Commands

```bash
# Create a task
bd create "Feature: Add dark mode" -p 0

# List ready tasks (no blockers)
bd ready

# Show task details
bd show <task-id>

# Mark in progress
bd update <task-id> --status in-progress

# Complete a task
bd done <task-id> "Implemented dark mode with theme switcher"
```

### Agent Workflow

Agents automatically use Beads in any repository:

```bash
# Orchestrator creates epic
bd create "Epic: Refactor auth system" -p 0

# Creates subtasks
bd create "Design: New auth flow" --parent <epic-id>
bd create "Implement: JWT tokens" --parent <epic-id>
bd create "Test: Auth endpoints" --parent <epic-id>

# Agents query ready work
bd ready

# Pick a task and work on it
bd update <task-id> --status in-progress

# Complete with notes
bd done <task-id> "Completed implementation. Tests passing."
```

## Stealth Mode Details

**All .beads/ directories are gitignored globally:**
- Tasks are **local-only** to your machine
- Never committed to git
- Won't pollute work/client repositories
- Perfect for personal task tracking

## Per-Repository Check

```bash
cd ~/projects/some-repo

# Is Beads initialized?
[ -d .beads ] && echo "✅ Initialized" || echo "❌ Not initialized"

# Is it gitignored?
git check-ignore .beads && echo "✅ Gitignored (stealth)" || echo "⚠️  Not gitignored"

# Show tasks
bd ready
```

## New Repository Setup

When you create a new repository:

```bash
cd ~/projects/new-repo
git init
bd init  # Initialize Beads

# .beads/ is automatically gitignored (global config)
git status  # Won't show .beads/
```

## Troubleshooting

### bd command not found
```bash
# Re-apply NixOS config
sudo nixos-rebuild switch --flake .#laptop
```

### Repository not initialized
```bash
cd ~/projects/repo
bd init
```

### Want to check if tasks are gitignored
```bash
# Should return ".beads" (meaning it's ignored)
git check-ignore .beads
```

## Documentation

- **[BEADS_AGENT_GUIDE.md](./BEADS_AGENT_GUIDE.md)** - Complete reference for all 14 agents
- **[BEADS_EXAMPLES.md](./BEADS_EXAMPLES.md)** - Real multi-agent scenarios
- **[BEADS_WORKFLOWS.md](./BEADS_WORKFLOWS.md)** - Step-by-step agent procedures
- **[BEADS_HIERARCHY.md](./BEADS_HIERARCHY.md)** - Task structure and dependencies

## Quick Reference

| Command | Description |
|---------|-------------|
| `bd init` | Initialize Beads in current repo |
| `bd create "Title" -p 0` | Create high-priority task |
| `bd ready` | List tasks ready to work on |
| `bd show <id>` | View task details |
| `bd update <id> --status in-progress` | Mark task as in progress |
| `bd done <id> "Summary"` | Complete task with notes |
| `bd list` | List all tasks |
| `bd dep add <parent> <child>` | Create dependency |

---

**All set! Your agents now have persistent memory across all repositories.**
