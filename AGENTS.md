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
