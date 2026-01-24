# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git

# Knowledge Management
bd list --label knowledge              # Find research/knowledge
bd update <id> --add-label knowledge   # Mark as knowledge
bd create "Research: topic" --type task --priority P1  # Create research issue
```

## Knowledge Persistence with Beads

Research and analysis should be PRESERVED, not forgotten. Follow this workflow:

### For Research/Analysis Tasks:
1. Create issue: `bd create "Research: topic" --type task --priority P1`
2. Do the research, add findings to issue description
3. When done: `bd update <id> --add-label knowledge,reference`
4. Keep the issue OPEN - do NOT close research issues

### For Implementation Tasks:
1. Create as child of research: `bd create "Implement: feature" --parent <research-id>`
2. Do the implementation
3. Close when done: `bd close <id>`

### Finding Knowledge Later:
- `bd list --label knowledge` - All research/knowledge
- `bd list --label reference` - Reference documentation
- `bd show <id>` - View full details with description

### Label Taxonomy:
- `knowledge` - Research findings, analysis, decisions
- `reference` - Documentation, guides, how-tos
- `research` - Active research in progress
- `implementation` - Code changes, features
- `bug` - Bug fixes
- `security` - Security-related

### Example Workflow:
```bash
# 1. Create research issue
bd create "Research: Blue light filter options for Wayland" --type task --priority P1

# 2. Add findings to the issue
bd update system-abc --description "## Findings
- wlsunset: Simple, lightweight, works with wlroots
- gammastep: Fork of redshift with Wayland support
- Recommendation: Use gammastep for feature parity with X11

## Configuration
Add to home.nix:
services.gammastep = {
  enable = true;
  latitude = \"37.7749\";
  longitude = \"-122.4194\";
};"

# 3. Mark as knowledge
bd update system-abc --add-label knowledge,reference

# 4. Keep it open! Create child for implementation
bd create "Implement: Add gammastep to NixOS config" --parent system-abc --type task

# 5. Later, find the knowledge
bd list --label knowledge
bd show system-abc  # Get all the research details
```

## Task Sizing Rules - Preventing Stuck Agents

All agents have built-in task sizing limits to prevent getting stuck or spinning indefinitely.

### Fast Agents (Haiku) - ≤3 Minutes
**Agents**: `explore`, `research`, `fix`, `plan`

**Rules**:
- Tasks must be completable in **3 minutes or less**
- Focus on **ONE specific thing**
- If task is bigger, **STOP and report back** with breakdown

**Examples of good tasks**:
- "Find all files matching pattern X"
- "Search for usage of function Y"
- "Fix this specific null pointer error"
- "Break down this feature into 3-5 subtasks"

**What to do if stuck**:
1. Stop working after 3 minutes
2. Report what you've found so far
3. Suggest how to break down the remaining work
4. Don't try to force completion

### Balanced Agents (Sonnet) - ≤10 Minutes
**Agents**: `general`, `build`, `test`, `review`, `refactor`, `debug`, `document`, `optimize`, `nix-specialist`, `security`, `architect`

**Rules**:
- Tasks should complete in **10 minutes or less**
- Well-scoped with clear deliverables
- If bigger, break down or ask orchestrator to split

**Examples of good tasks**:
- "Implement function X with error handling"
- "Write unit tests for module Y"
- "Review security of authentication flow"
- "Document the API for feature Z"

**What to do if running long**:
1. Create a checkpoint (commit partial work)
2. Report progress and what remains
3. Continue if close to done, or ask for re-scoping

### Complex Orchestration (Opus) - ≤15 Minutes per Phase
**Agent**: `orchestrator`

**Rules**:
- Break large workflows into **phases of ≤15 minutes**
- Each delegated task should be ≤10 min for subagents
- Monitor subagent progress actively

**Examples of good orchestration**:
- Phase 1: Research and design (parallel: research + architect)
- Phase 2: Implementation (parallel: build + test)
- Phase 3: Quality (parallel: review + security + optimize)

**What to do if subagent is stuck**:
1. Intervene after reasonable time
2. Re-scope the task into smaller pieces
3. Try different approach or different agent
4. Don't let subagents spin indefinitely

### General Principles

**For ALL agents**:
- ✅ Break down large tasks proactively
- ✅ Report progress regularly
- ✅ Ask for help when stuck
- ✅ Commit partial work to avoid losing progress
- ❌ Don't try to force completion of oversized tasks
- ❌ Don't spin indefinitely on unclear problems
- ❌ Don't guess at requirements - ask for clarification

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**

- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
