# Beads Agent Guide: Shared Persistent Memory for AI Agents

**Version**: 1.0  
**Last Updated**: 2026-01-23  
**Purpose**: Enable 14 AI agents to maintain shared context and coordinate work through git-backed task tracking

---

## 1. Overview: Why Beads?

### The Context Loss Problem

AI agents face a critical limitation: **they forget everything between invocations**. Each time an agent starts:

- No memory of previous work
- Must re-research the codebase
- Cannot see what other agents did
- Duplicate effort constantly
- No coordination between agents

### The Beads Solution

**Beads** is a git-backed issue tracker that provides **shared persistent memory** for all agents:

- **Git-backed**: Task state stored in `.beads/issues/` (committed to repo)
- **Always available**: Every agent can read/write shared memory
- **Persistent**: Survives agent restarts, context windows, sessions
- **Structured**: Tasks, epics, dependencies, status tracking
- **Collaborative**: 14 agents coordinate through shared task board

**Key Insight**: Beads transforms ephemeral AI agents into a persistent, coordinated development team.

### What Gets Stored

```
.beads/
├── issues/           # Task data (COMMITTED to git)
│   ├── 001.json     # Individual task files
│   ├── 002.json
│   └── epic-*.json  # Epic/parent tasks
├── cache/           # Local only (GITIGNORED)
└── db/              # Local index (GITIGNORED)
```

Only `issues/` is committed - this is your agents' shared brain.

---

## 2. Core Concepts

### Task Anatomy

```json
{
  "id": "042",
  "title": "Implement user authentication",
  "status": "in-progress",
  "priority": "P1",
  "assignee": "build",
  "epic": "015",
  "tags": ["security", "backend"],
  "dependencies": ["041"],
  "created": "2026-01-23T10:30:00Z",
  "updated": "2026-01-23T14:22:00Z"
}
```

### Status Lifecycle

```
backlog → ready → in-progress → done → closed
   ↓         ↓          ↓          ↓
 (planned) (unblocked) (active) (complete)
```

- **backlog**: Created but not ready to work on (may have blockers)
- **ready**: Unblocked and available for work
- **in-progress**: Currently being worked on by an agent
- **done**: Work complete, pending verification
- **closed**: Verified and archived

### Priority Levels

- **P0**: Critical (blocking, security issues, system down)
- **P1**: High (important features, major bugs)
- **P2**: Medium (normal features, minor improvements)
- **P3**: Low (nice-to-have, future enhancements)

**Default**: P1 (configured in `~/.config/beads/config.toml`)

### Epics (Parent Tasks)

Epics group related subtasks into a coordinated workflow:

```
Epic #015: User Authentication System
├── Task #041: Design auth architecture (architect) ✓
├── Task #042: Implement JWT middleware (build) ⚙
├── Task #043: Add rate limiting (security) □
├── Task #044: Write integration tests (test) □
└── Task #045: Document auth flow (document) □
```

**Use epics when**: Orchestrator delegates a complex feature to multiple agents.

### Dependencies

Three relationship types:

1. **blocks**: Task A must complete before Task B can start

   ```bash
   bd dep add 042 --blocks 043  # 042 blocks 043
   ```

2. **related**: Tasks are connected but independent

   ```bash
   bd dep add 042 --related 044  # 042 related to 044
   ```

3. **parent-child**: Epic contains subtasks
   ```bash
   bd create "Subtask" --epic 015  # Auto-creates parent link
   ```

---

## 3. Agent Roles: How Each Agent Uses Beads

### Primary Agents (3)

#### Orchestrator (Opus)

**Role**: Multi-agent coordinator and epic creator

**Beads Usage**:

- Creates epics for complex multi-step workflows
- Breaks epics into subtasks assigned to specialists
- Monitors overall progress across all tasks
- Resolves inter-agent dependencies
- Escalates blocked tasks

**Typical Commands**:

```bash
# Create an epic
bd create "Epic: Add export feature" --priority P1 --tag epic

# Create subtasks
bd create "Design export architecture" --epic 015 --assign architect
bd create "Implement CSV export" --epic 015 --assign build
bd create "Security review export" --epic 015 --assign security
bd create "Document export API" --epic 015 --assign document

# Monitor progress
bd show 015  # Show epic with all subtasks
bd list --epic 015 --status in-progress
```

**When to use**: User requests complex features requiring 3+ agents.

---

#### Architect (Sonnet)

**Role**: System designer and technical planner

**Beads Usage**:

- Records architectural decisions in tasks
- Creates design tasks before implementation
- Documents technical constraints and requirements
- Links design tasks to implementation tasks
- Reviews completed work against design specs

**Typical Commands**:

```bash
# Create design task
bd create "Design data model for exports" --priority P1 --tag architecture

# Record decision
bd update 042 --description "Using PostgreSQL JSONB for flexible schema. See ADR-015."

# Link design to implementation
bd dep add 041 --blocks 042  # Design must complete first

# Mark complete with notes
bd done 041 --comment "Architecture documented in docs/architecture/exports.md"
```

**When to use**: Before any major feature implementation.

---

#### Build (Sonnet)

**Role**: Code implementation specialist

**Beads Usage**:

- Picks ready implementation tasks from queue
- Marks tasks in-progress while working
- Creates follow-up tasks for discovered work
- Delegates testing/review/docs to specialists
- Marks tasks done when code is written

**Typical Commands**:

```bash
# Find work
bd ready --tag implementation --priority P0,P1

# Start work
bd update 042 --status in-progress --assign build

# Delegate testing
bd create "Test CSV export edge cases" --blocks 042 --assign test

# Complete task
bd done 042 --comment "Implemented in lib/export/csv.rs. Tests needed."
```

**When to use**: Every coding session - pick tasks, delegate, complete.

---

### Subagents (11)

#### Plan (Haiku)

**Role**: Fast task breakdown specialist

**Beads Usage**:

- Breaks epics into actionable subtasks
- Estimates task complexity
- Identifies dependencies
- Creates task sequences

**Commands**:

```bash
bd create "Research current implementation" --priority P2 --tag planning
bd create "Identify refactoring opportunities" --epic 020 --assign plan
bd done 056 --comment "Created 5 subtasks for epic #020"
```

---

#### Review (Sonnet)

**Role**: Code quality and QA specialist

**Beads Usage**:

- Picks review tasks from queue
- Documents findings in task comments
- Creates follow-up tasks for issues found
- Marks reviews complete

**Commands**:

```bash
bd ready --tag review
bd update 043 --status in-progress --assign review
bd create "Fix SQL injection in export query" --priority P0 --blocks 043
bd done 043 --comment "Found 3 issues. Created tasks #057-059 for fixes."
```

---

#### Test (Sonnet)

**Role**: Testing and TDD specialist

**Beads Usage**:

- Creates test tasks for new features
- Tracks test coverage gaps
- Documents failing tests
- Links tests to implementation

**Commands**:

```bash
bd create "Add unit tests for export validation" --priority P1 --tag testing
bd dep add 042 --blocks 060  # Can't test until implemented
bd done 060 --comment "96% coverage. All tests passing."
```

---

#### Security (Sonnet)

**Role**: Security analysis and hardening

**Beads Usage**:

- Performs security reviews on completed features
- Creates vulnerability fix tasks
- Tracks security-related work
- Documents security decisions

**Commands**:

```bash
bd ready --tag security
bd create "Audit authentication token handling" --priority P0 --tag security
bd done 061 --comment "No vulnerabilities found. Rate limiting recommended."
```

---

#### Document (Sonnet)

**Role**: Technical documentation specialist

**Beads Usage**:

- Tracks documentation tasks
- Ensures every feature has docs
- Creates user guides and API docs
- Links docs to implementations

**Commands**:

```bash
bd create "Document export API endpoints" --epic 015 --assign document
bd dep add 042 --blocks 062  # Can't document until implemented
bd done 062 --comment "Added to docs/api/export.md and updated README"
```

---

#### Debug (Sonnet)

**Role**: Systematic problem solver

**Beads Usage**:

- Investigates bug reports
- Documents debugging findings
- Creates fix tasks
- Tracks reproduction steps

**Commands**:

```bash
bd create "Debug crash in CSV export with 10k+ rows" --priority P0 --tag bug
bd update 063 --description "Root cause: memory overflow in buffer. Fix in progress."
bd done 063 --comment "Fixed by streaming export. Added regression test."
```

---

#### Research (Haiku)

**Role**: Codebase exploration and investigation

**Beads Usage**:

- Explores unknown areas before work starts
- Documents findings for other agents
- Creates research tasks
- Answers specific questions

**Commands**:

```bash
bd create "Research how current CSV export works" --assign research --tag investigation
bd done 064 --comment "Current impl in lib/csv.go. Uses 3rd party library. See notes."
```

---

#### Optimize (Sonnet)

**Role**: Performance optimization specialist

**Beads Usage**:

- Tracks performance improvement tasks
- Documents benchmarks
- Creates optimization tasks
- Links optimizations to features

**Commands**:

```bash
bd create "Optimize export query performance" --priority P2 --tag performance
bd done 065 --comment "Reduced query time from 5s to 0.3s. Added indexes."
```

---

#### Refactor (Sonnet)

**Role**: Code quality and maintainability

**Beads Usage**:

- Identifies refactoring opportunities
- Tracks technical debt
- Creates cleanup tasks
- Documents refactoring decisions

**Commands**:

```bash
bd create "Refactor export module for better testability" --priority P2 --tag refactor
bd done 066 --comment "Extracted interfaces. 100% unit testable now."
```

---

#### Nix-Specialist (Sonnet)

**Role**: NixOS configuration expert

**Beads Usage**:

- Tracks NixOS module changes
- Documents configuration decisions
- Creates system config tasks
- Links configs to features

**Commands**:

```bash
bd create "Add export service to NixOS module" --priority P1 --tag nixos
bd done 067 --comment "Added to modules/services/export.nix with options."
```

---

#### Fix (Haiku)

**Role**: Fast bug fix specialist

**Beads Usage**:

- Handles quick bug fixes
- Tracks simple fixes
- Creates follow-up tasks if needed
- Fast iteration on small issues

**Commands**:

```bash
bd ready --tag bug --priority P0,P1
bd update 068 --status in-progress --assign fix
bd done 068 --comment "Quick fix applied. Works now."
```

---

#### Explore (Haiku)

**Role**: Fast codebase discovery

**Beads Usage**:

- Quick exploration tasks
- Answers specific questions
- Documents file locations
- Maps codebase structure

**Commands**:

```bash
bd create "Find all export-related files" --assign explore --tag discovery
bd done 069 --comment "Found 12 files. Listed in task notes."
```

---

#### General (Sonnet)

**Role**: Multi-purpose agent for miscellaneous work

**Beads Usage**:

- Handles tasks that don't fit other agents
- General maintenance work
- Cross-cutting concerns
- Fallback for unassigned work

**Commands**:

```bash
bd ready --status backlog --assignee none
bd update 070 --assign general
bd done 070 --comment "Completed miscellaneous cleanup."
```

---

## 4. Essential Commands

### Initialize (once per repo)

```bash
cd /path/to/project
bd init
git add .beads/
git commit -m "Initialize Beads task tracking"
```

### Create Tasks

```bash
# Basic task
bd create "Fix login bug"

# With priority and tags
bd create "Add export feature" --priority P1 --tag feature,backend

# As subtask of epic
bd create "Design export API" --epic 015 --assign architect

# With description
bd create "Refactor auth" --description "Extract middleware, improve testability"
```

### Query Tasks

```bash
# List all ready tasks
bd ready

# List by status
bd list --status in-progress
bd list --status done

# List by assignee
bd list --assignee build
bd list --assignee test --status ready

# List by priority
bd list --priority P0,P1

# List by tag
bd list --tag security
bd list --tag bug --status ready

# List epic's subtasks
bd list --epic 015
```

### Show Task Details

```bash
# Full task info
bd show 042

# Show with comments
bd show 042 --comments

# Show with dependencies
bd show 042 --deps
```

### Update Tasks

```bash
# Change status
bd update 042 --status in-progress
bd ready 042  # Shortcut for --status ready

# Assign to agent
bd update 042 --assign build

# Change priority
bd update 042 --priority P0

# Add tags
bd update 042 --tag security,urgent

# Update description
bd update 042 --description "New detailed description"
```

### Manage Dependencies

```bash
# Task A blocks Task B
bd dep add 041 --blocks 042

# Tasks are related
bd dep add 042 --related 043

# Remove dependency
bd dep remove 041 042
```

### Complete Tasks

```bash
# Mark done (simple)
bd done 042

# Mark done with comment
bd done 042 --comment "Implemented in lib/auth.rs. Tests pass."

# Move to ready (unblock)
bd ready 042

# Close (archive)
bd close 042
```

### Search and Filter

```bash
# Text search in titles
bd list --search "export"

# Combine filters
bd list --assignee build --priority P1 --status ready --tag feature

# Find my work
bd list --assignee $(whoami) --status in-progress
```

### Git Integration

```bash
# Beads auto-commits to git when tasks change
# Manual sync if needed:
git add .beads/issues/
git commit -m "Update task status"
git push

# Pull latest task state
git pull
```

---

## 5. Task Lifecycle

### Standard Flow

```
1. CREATE    → Orchestrator/Architect creates task
               bd create "New feature" --priority P1

2. READY     → Task unblocked and ready for work
               bd ready 042

3. ASSIGN    → Agent picks task and marks in-progress
               bd update 042 --status in-progress --assign build

4. WORK      → Agent implements/investigates/documents
               (Agent does work, may create subtasks)

5. DONE      → Agent completes task with notes
               bd done 042 --comment "Completed. See commit abc123."

6. VERIFY    → Review agent or Orchestrator verifies
               bd show 042 --comments

7. CLOSE     → Orchestrator archives completed task
               bd close 042
```

### With Dependencies

```
Epic #015: Export Feature
│
├─ Task #041: Design (architect)
│   └─ blocks → #042, #043
│
├─ Task #042: Implement (build)  ← Blocked until #041 done
│   └─ blocks → #044
│
├─ Task #043: Security review (security) ← Blocked until #041 done
│   └─ related → #042
│
├─ Task #044: Tests (test)  ← Blocked until #042 done
│   └─ blocks → #045
│
└─ Task #045: Documentation (document)  ← Blocked until #044 done

Flow:
1. Orchestrator creates epic + 5 subtasks
2. Only #041 is "ready" (no blockers)
3. Architect completes #041 → unblocks #042, #043
4. Build works on #042, Security works on #043 (parallel!)
5. Build completes #042 → unblocks #044
6. Test completes #044 → unblocks #045
7. Document completes #045
8. Epic #015 complete!
```

---

## 6. Dependency Types

### Blocking Dependencies

**Use when**: Task B cannot start until Task A completes

```bash
# Design must complete before implementation
bd dep add 041 --blocks 042

# Implementation must complete before tests
bd dep add 042 --blocks 044
```

**Effect**: Task #042 stays in `backlog` until #041 is `done`.

### Related Dependencies

**Use when**: Tasks are connected but can work in parallel

```bash
# Security review and implementation happen together
bd dep add 042 --related 043
```

**Effect**: Informational only - helps agents see context.

### Parent-Child (Epic) Dependencies

**Use when**: Grouping related tasks under an epic

```bash
# Create epic
bd create "Epic: Export Feature" --tag epic --priority P1

# Create subtasks
bd create "Design export" --epic 015
bd create "Implement export" --epic 015
bd create "Test export" --epic 015
```

**Effect**: Subtasks appear under epic. Epic status tracks completion.

---

## 7. Workflow Patterns

### Pattern 1: Sequential Delegation (Design → Build → Test)

**Orchestrator starts**:

```bash
bd create "Epic: Add two-factor authentication" --priority P1 --tag epic
bd create "Design 2FA architecture" --epic 020 --assign architect --priority P1
bd dep add 071 --blocks 072  # Design blocks implementation
bd create "Implement 2FA backend" --epic 020 --assign build --priority P1
bd dep add 072 --blocks 073  # Implementation blocks tests
bd create "Test 2FA flows" --epic 020 --assign test --priority P1
```

**Architect**:

```bash
bd ready  # Shows task #071
bd update 071 --status in-progress
# ... does design work ...
bd done 071 --comment "Architecture in docs/design/2fa.md"
# → Task #072 automatically becomes "ready"
```

**Build**:

```bash
bd ready  # Shows task #072 (now unblocked)
bd update 072 --status in-progress
# ... implements 2FA ...
bd done 072 --comment "Implemented in lib/auth/2fa.rs"
# → Task #073 automatically becomes "ready"
```

**Test**:

```bash
bd ready  # Shows task #073 (now unblocked)
bd update 073 --status in-progress
# ... writes tests ...
bd done 073 --comment "95% coverage. All tests pass."
```

**Orchestrator verifies**:

```bash
bd show 020  # Shows epic with all subtasks complete
bd close 071 072 073 020  # Archive all
```

---

### Pattern 2: Parallel Delegation (Research + Security + Docs)

**Orchestrator starts**:

```bash
bd create "Epic: Audit authentication system" --priority P0 --tag epic,security
bd create "Research auth vulnerabilities" --epic 021 --assign research --priority P0
bd create "Security audit JWT implementation" --epic 021 --assign security --priority P0
bd create "Security audit session management" --epic 021 --assign security --priority P0
bd create "Document security findings" --epic 021 --assign document --priority P1
bd dep add 074 --related 075  # Research informs security work
bd dep add 075 076 --blocks 077  # Both audits must complete before docs
```

**All agents work in parallel**:

```bash
# Research (Haiku) - fast exploration
bd update 074 --status in-progress
bd done 074 --comment "Found 3 potential issues. See notes."

# Security (Sonnet) - thorough analysis
bd update 075 --status in-progress
bd done 075 --comment "JWT secure. Recommended: add token rotation."

# Security (Sonnet) - another agent or same, different task
bd update 076 --status in-progress
bd done 076 --comment "Session timeout too long. Created fix task #080."

# Document (Sonnet) - waits for #075 and #076
bd ready  # Shows #077 (now unblocked)
bd update 077 --status in-progress
bd done 077 --comment "Security report in docs/security/audit-2026-01.md"
```

**Result**: 3 agents working simultaneously, coordinated through dependencies.

---

### Pattern 3: Iterative Debugging (Debug → Fix → Test → Verify)

**User reports bug**:

```bash
bd create "App crashes on large CSV export" --priority P0 --tag bug,urgent
```

**Debug investigates**:

```bash
bd update 081 --status in-progress --assign debug
# ... investigates ...
bd update 081 --description "Root cause: memory overflow when buffer exceeds 1GB"
bd create "Fix CSV export memory overflow" --priority P0 --tag bug,fix --assign fix
bd dep add 081 --blocks 082  # Debug informs fix
bd done 081 --comment "Root cause found. Created fix task #082."
```

**Fix implements**:

```bash
bd update 082 --status in-progress
# ... implements streaming export ...
bd create "Test CSV export with large datasets" --priority P0 --assign test
bd dep add 082 --blocks 083  # Can't test until fixed
bd done 082 --comment "Implemented streaming. Ready for testing."
```

**Test verifies**:

```bash
bd update 083 --status in-progress
# ... tests with 100k+ row CSVs ...
bd done 083 --comment "Tested with 500k rows. No crash. Memory stable."
```

**Review confirms**:

```bash
bd create "Review CSV export fix" --priority P1 --assign review
bd update 084 --status in-progress
bd done 084 --comment "Code looks good. Approved for merge."
bd close 081 082 083 084  # Archive entire debugging workflow
```

---

## 8. Examples: Multi-Agent Scenarios

### Example 1: New Feature (Export to PDF)

**User request**: "Add ability to export reports as PDF"

**Orchestrator**:

```bash
# Create epic
bd create "Epic: PDF Export Feature" --priority P1 --tag feature,export

# Break into tasks
bd create "Research PDF generation libraries" --epic 085 --assign research --priority P1
bd create "Design PDF export architecture" --epic 085 --assign architect --priority P1
bd dep add 086 087 --blocks 088  # Research + Design before implementation
bd create "Implement PDF generation service" --epic 085 --assign build --priority P1
bd dep add 088 --blocks 089 090  # Implementation before parallel QA
bd create "Write PDF export tests" --epic 085 --assign test --priority P1
bd create "Security review PDF generation" --epic 085 --assign security --priority P1
bd dep add 089 090 --blocks 091  # Tests + Security before docs
bd create "Document PDF export API" --epic 085 --assign document --priority P1
```

**Execution**:

1. Research + Architect work in parallel (independent)
2. Build waits for both to complete
3. Test + Security work in parallel after Build completes
4. Document waits for Test + Security
5. Total time: ~3 stages instead of 6 sequential

---

### Example 2: Critical Bug Fix

**User report**: "Login completely broken - P0"

**Orchestrator**:

```bash
# Immediate priority
bd create "CRITICAL: Login system down" --priority P0 --tag bug,urgent

# Fast investigation
bd create "Debug login failure cause" --priority P0 --assign debug
bd dep add 092 --blocks 093
bd create "Implement emergency fix" --priority P0 --assign fix
bd dep add 093 --blocks 094
bd create "Verify login works" --priority P0 --assign test
```

**Debug** (10 min):

```bash
bd update 092 --status in-progress
bd done 092 --comment "Database connection pool exhausted. Max connections too low."
# → Unblocks Fix
```

**Fix** (15 min):

```bash
bd update 093 --status in-progress
bd done 093 --comment "Increased pool size from 10 to 100. Login restored."
# → Unblocks Test
```

**Test** (10 min):

```bash
bd update 094 --status in-progress
bd done 094 --comment "Login working. 100 concurrent users tested successfully."
```

**Follow-up**:

```bash
bd create "Implement connection pool monitoring" --priority P1 --assign build
bd create "Document connection pool configuration" --priority P2 --assign document
```

**Total time**: ~35 minutes instead of hours of context switching.

---

### Example 3: System Configuration Change

**User request**: "Enable Redis caching in NixOS config"

**Orchestrator**:

```bash
bd create "Epic: Add Redis caching to system" --priority P1 --tag nixos,infrastructure

bd create "Design caching architecture" --epic 095 --assign architect
bd create "Research Redis NixOS module options" --epic 095 --assign nix-specialist
bd dep add 096 097 --blocks 098  # Design + Research before implementation

bd create "Implement Redis NixOS module" --epic 095 --assign nix-specialist
bd dep add 098 --blocks 099 100  # Implementation before parallel review

bd create "Security review Redis config" --epic 095 --assign security
bd create "Test Redis integration" --epic 095 --assign test
bd dep add 099 100 --blocks 101  # Both reviews before docs

bd create "Document Redis configuration" --epic 095 --assign document
```

**Architect** + **Nix-Specialist** work in parallel, then:
**Nix-Specialist** implements while **Security** + **Test** prepare review plans, then:
**Security** + **Test** review in parallel, then:
**Document** writes final docs.

**Result**: Clear coordination across NixOS-specific work.

---

## Key Takeaways

### For All Agents

1. **Check Beads first**: `bd ready --assign $(whoami)` before starting work
2. **Update status**: Mark tasks `in-progress` when working
3. **Create follow-ups**: Found more work? Create tasks for other agents
4. **Complete with notes**: Always `bd done` with comments explaining what was done
5. **Respect dependencies**: Don't start blocked tasks - check `bd show <id> --deps`

### For Orchestrator

1. **Think in epics**: Complex features → epic + subtasks
2. **Parallel when possible**: Mark independent tasks as ready simultaneously
3. **Use dependencies wisely**: Block for strict ordering, related for context
4. **Delegate aggressively**: Let specialists do specialized work
5. **Monitor progress**: `bd show <epic-id>` shows overall status

### For Specialists

1. **Stay in lane**: Build codes, Test tests, Document documents
2. **Delegate out**: Found security issue? Create task for Security agent
3. **Document findings**: Comments help other agents build on your work
4. **Link related work**: Use `--related` to connect tasks
5. **Clear completion**: `bd done` with summary helps Orchestrator verify

---

## Quick Reference Card

```bash
# Essential Commands
bd init                          # Initialize Beads in repo
bd create "Title" --priority P1  # Create task
bd ready                         # Show all ready tasks
bd ready --assign build          # Show my ready tasks
bd update 042 --status in-progress  # Start work
bd done 042 --comment "Done!"    # Complete task
bd show 042                      # View task details

# Epic Management
bd create "Epic: Feature" --tag epic
bd create "Subtask" --epic 015
bd list --epic 015

# Dependencies
bd dep add 041 --blocks 042      # 041 must complete first
bd dep add 042 --related 043     # Related work

# Filtering
bd list --priority P0,P1
bd list --tag security --status ready
bd list --assignee test --status in-progress

# Aliases (configured in Beads module)
bdr    → bd ready
bdc    → bd create
bds    → bd show
bdl    → bd list
bdd    → bd done
```

---

**Remember**: Beads is your agents' shared brain. Use it religiously, and agents will stop forgetting, stop duplicating work, and start coordinating like a real development team.

**Next Steps**:

1. Run `bd init` in your project root
2. Commit `.beads/` to git
3. Have agents create tasks for current work
4. Watch coordination improve immediately

---

_This guide is part of the NixOS OpenCode system documentation. For OpenCode agent configuration, see `docs/OPENCODE-PARALLEL-INDEX.md`._
