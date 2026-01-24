# Beads Knowledge Persistence - Agent Workflow Guide

## The Problem & Solution

**Problem:** When research issues are closed, the knowledge becomes invisible because:
- `bd ready` doesn't show closed issues
- `bd list` defaults to open/in_progress only
- Agents forget findings exist and redo research

**Root Cause:** Workflow design issue, not tool limitation

**Solution:** Keep research issues OPEN + label appropriately

## Quick Start

### When You Complete Research:

1. **Keep it OPEN** (don't close)
   ```bash
   # DON'T do this:
   bd close system-XXXX
   
   # DO this instead:
   bd update system-XXXX --add-label knowledge,reference
   ```

2. **Label clearly**
   ```bash
   bd update system-XXXX --add-label knowledge,reference,documented
   ```

3. **Document status in notes**
   ```bash
   bd update system-XXXX --notes "Research complete Jan 24. Findings in description. Implementation in system-XXXX.1"
   ```

4. **Create separate implementation tasks**
   ```bash
   bd create "Implement: Feature X" --parent system-XXXX --type task
   # Close these implementation tasks after done
   # Keep the research issue open
   ```

## Pattern Overview

```
Research Epic (OPEN, labels: knowledge, reference)
├── Research Task 1 (OPEN, labels: knowledge)
├── Research Task 2 (OPEN, labels: knowledge)
└── Implementation Task (CLOSED when done, labels: implementation)
```

**Key Rule:** Research issues stay OPEN forever. Only close implementation tasks.

## Commands You'll Use

### Discovery
```bash
# Find all knowledge
bd list --label knowledge

# Find specific topic
bd list --label architecture
bd list --label performance
bd list --label security

# Search within
bd search "specific term" --label knowledge
```

### Creation
```bash
# Start research
bd create "Research: Topic Name" \
  --type epic \
  --label knowledge,reference \
  --description "Initial findings..."
```

### Updates
```bash
# Add findings
bd update system-XXXX --body-file research_findings.md

# Add status
bd update system-XXXX --notes "Completed investigation of X"

# Add comments for discussion
bd comments add system-XXXX "New insight: pattern discovered..."
```

### Export
```bash
# Backup to markdown weekly
bd export --format obsidian -o docs/knowledge-base.md

# Export specific topic
bd export --format obsidian --label architecture -o docs/architecture.md
```

## Label Taxonomy

Use these labels to organize knowledge:

**Meta Labels:**
- `knowledge` - This is preserved knowledge (not a task)
- `reference` - Keep accessible as reference
- `documented` - Analysis documented and complete
- `evergreen` - Topic continues to grow over time

**Topic Labels:**
- `architecture` - System design & structure
- `performance` - Optimization findings
- `security` - Security analysis
- `troubleshooting` - Problem-solving patterns
- `integration` - Multi-system interaction
- `configuration` - Setup guides

**Status Indicators:**
- `wip` - Work in progress research
- `ready-for-review` - Ready for team review
- `no-follow-up` - Archived, not being updated

## Real Examples from Repo

### Good Example: system-h49
```
Status: CLOSED but has extensive research (4,800+ lines)
Problem: Hidden from bd list by default
Solution: Reopen and add knowledge label
```

### Good Pattern: system-xts (Epic)
```
Status: OPEN (epic container)
├── system-xts.1 (OPEN) - Analyze flake structure (research)
├── system-xts.2 (CLOSED) - Fix gammastep (implementation - OK to close)
├── system-xts.3 (CLOSED) - Fix markdown (implementation - OK to close)
├── system-xts.4 (OPEN) - Analyze dev environment (research)
└── system-xts.5 (OPEN) - Analyze stability (research)

Result: Research stays visible, implementation can close
```

## Workflow Scenarios

### Scenario 1: Complete Research → Implementation

```bash
# Step 1: Create research epic
bd create "Research: River WM Configuration" \
  --type epic \
  --label knowledge,reference \
  --description "$(cat research.md)"
# Output: system-XXXX

# Step 2: Add detailed findings
bd update system-XXXX --body-file detailed_findings.md

# Step 3: Create implementation subtask
bd create "Remove gaps from River WM" \
  --parent system-XXXX \
  --type task

# Step 4: Complete implementation
# ... do the work ...
# bd close system-XXXX.1  (close only the implementation task)

# Step 5: Research stays open
bd list --label knowledge
# system-XXXX shows up here forever
```

### Scenario 2: Reopen Closed Research

```bash
# You find old valuable research that was closed
bd show system-2s0  # Contains 4,000+ lines

# Reopen it
bd reopen system-2s0

# Add knowledge labels
bd update system-2s0 --add-label knowledge,reference,documentation

# Reference it going forward
bd list --label knowledge  # Now shows it
```

### Scenario 3: Multi-Issue Research

```bash
# Master research epic
bd create "Research: NixOS Hardening" \
  --type epic \
  --label knowledge \
  --description "Master findings on hardening NixOS systems"
# Output: system-RESEARCH

# Sub-research #1
bd create "Research: Kernel Hardening" \
  --parent system-RESEARCH \
  --label knowledge \
  --description "Kernel sysctls and boot parameters"

# Sub-research #2
bd create "Research: Sudo Hardening" \
  --parent system-RESEARCH \
  --label knowledge

# Implementation (separate, can close)
bd create "Implement: Create hardening.nix module" \
  --parent system-RESEARCH \
  --type task

# Later: close only implementation
# Keep all research open
```

## Key Insights

### What's Preserved
✅ Description (unlimited markdown)
✅ Comments (append-only discussion)
✅ Notes (status updates)
✅ Labels (categorization)
✅ All stored in `issues.jsonl` (git-backed)
✅ Exported to markdown weekly

### What's NOT Preserved (If You Close)
❌ Closed issues hidden from `bd ready`
❌ Closed issues hidden from default `bd list`
❌ Hard to rediscover without searching
❌ "Forgotten" for future agents

### Solution
Keep research OPEN + label appropriately = Always discoverable

## Git Integration

### Auto-Export Knowledge Base

Add to your workflow:

```bash
# Manual (do weekly)
bd export --format obsidian -o docs/KNOWLEDGE-BASE.md
git add docs/KNOWLEDGE-BASE.md
git commit -m "Weekly knowledge base export"

# Or set up cron job
# 0 9 * * 1 bd export --format obsidian -o docs/KNOWLEDGE-BASE.md
```

### View Git History of Knowledge

```bash
# See when knowledge was added/updated
git log --oneline .beads/issues.jsonl

# See changes to specific issue
git log -p --all -S '"id":"system-XXXX"' .beads/issues.jsonl
```

## Summary Commands

```bash
# See what knowledge we have
bd list --label knowledge

# Find specific area
bd list --label architecture
bd list --label performance

# Search within knowledge
bd search "thread pool" --label knowledge

# Show a specific item
bd show system-XXXX

# Export for backup
bd export --format obsidian -o docs/KNOWLEDGE-BASE.md
```

## Anti-Patterns (Don't Do)

❌ Close research issues (makes invisible)
❌ Mix research and implementation (separate into parent/child)
❌ Store research only in closed issues
❌ Forget to export/commit knowledge backups
❌ Use `bd search` without understanding defaults
❌ Let knowledge base grow stale (review quarterly)

## Questions?

Reference the master research issue:
```bash
bd show system-avb  # Complete analysis with architecture details
```

That issue contains:
- Full beads data structure documentation
- All available fields and their uses
- Capabilities vs limitations
- Implementation checklists
- Best practices and examples
