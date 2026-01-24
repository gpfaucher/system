# Beads Hierarchy: Task Structure & Dependency Patterns

**Version**: 1.0  
**Last Updated**: 2026-01-23  
**Purpose**: Visual reference for organizing tasks, epics, and dependencies in Beads

---

## Overview

This document provides **visual patterns** for structuring work in Beads. It covers:

- Task ID system and hierarchy
- Epic → Task → Subtask structures
- When to use each level
- Common dependency patterns
- Visual dependency graphs

Use this as a **quick reference** when planning complex multi-agent work.

---

## Task ID System

### ID Format

Beads uses a hierarchical ID system to show task relationships:

```
bd-a1b2c3         # Root task (epic or standalone)
bd-a1b2c3.1       # Subtask level 1
bd-a1b2c3.1.1     # Subtask level 2
bd-a1b2c3.1.2     # Subtask level 2
bd-a1b2c3.2       # Subtask level 1
bd-a1b2c3.2.1     # Subtask level 2
```

### Numeric IDs

For simplicity, Beads also assigns sequential numeric IDs:

```
Task #042         # Refers to bd-a1b2c3
Task #043         # Refers to bd-a1b2c3.1
Task #044         # Refers to bd-a1b2c3.1.1
```

**In commands**: Use numeric IDs for brevity (`bd show 042`), but hierarchical IDs show structure.

---

## Hierarchy Levels

### Level 1: Epics (Parent Tasks)

**Purpose**: Group related work into a coordinated feature or initiative

**When to use**:

- Complex feature requiring 3+ agents
- Multi-phase project with dependencies
- Large refactoring with parallel work
- Any work spanning multiple days

**Characteristics**:

- Tagged with `epic`
- Contains 3+ subtasks
- Assigned to Orchestrator or Architect
- Usually P1 priority

**Example**:

```bash
bd create "Epic: User authentication system" \
  --priority P1 \
  --tag epic,feature \
  --assign orchestrator
```

---

### Level 2: Tasks (Primary Work Units)

**Purpose**: Discrete, actionable work that can be completed by one agent in one session

**When to use**:

- Specific implementation work
- Design tasks
- Testing tasks
- Documentation tasks
- Bug fixes

**Characteristics**:

- Part of an epic (usually) or standalone
- Assigned to specific agent
- Completable in 30-180 minutes
- Has clear done criteria

**Example**:

```bash
bd create "Implement JWT authentication middleware" \
  --epic 042 \
  --assign build \
  --priority P1
```

---

### Level 3: Subtasks (Micro Work Units)

**Purpose**: Break down complex tasks into smaller steps

**When to use**:

- Task is too large for one session (>3 hours)
- Task has multiple distinct phases
- Want to track progress within a task
- Multiple agents contribute to one task

**Characteristics**:

- Child of a task
- Very specific and granular
- Completable in <60 minutes
- May not need separate agent assignment

**Example**:

```bash
bd create "Write unit tests for JWT token generation" \
  --epic 043 \
  --assign test \
  --priority P1
```

---

## Visual Hierarchy Patterns

### Pattern 1: Simple Epic (Sequential)

```
Epic #100: Add Export Feature
│
├── Task #101: Design export architecture (architect)
│   └── Status: done
│
├── Task #102: Implement CSV export (build)
│   ├── Status: in-progress
│   └── Blocked by: 101
│
├── Task #103: Implement PDF export (build)
│   ├── Status: backlog
│   └── Blocked by: 101
│
├── Task #104: Write export tests (test)
│   ├── Status: backlog
│   └── Blocked by: 102, 103
│
└── Task #105: Document export API (document)
    ├── Status: backlog
    └── Blocked by: 104
```

**Dependency Flow**:

```
101 → 102 → 104 → 105
101 → 103 ↗
```

**Timeline**: 5 stages (serial execution)

---

### Pattern 2: Epic with Parallel Work

```
Epic #200: Authentication System
│
├── Task #201: Design auth architecture (architect)
│   └── Status: done
│
├── Task #202: Implement login API (build)
│   ├── Status: done
│   └── Blocked by: 201
│
├── Task #203: Implement OAuth flow (build)
│   ├── Status: done
│   └── Blocked by: 201
│   └── Related to: 202
│
├── Task #204: Security audit login (security)
│   ├── Status: in-progress
│   └── Blocked by: 202
│
├── Task #205: Security audit OAuth (security)
│   ├── Status: in-progress
│   └── Blocked by: 203
│
└── Task #206: Integration tests (test)
    ├── Status: backlog
    └── Blocked by: 204, 205
```

**Dependency Flow**:

```
       201
        │
    ┌───┴───┐
    │       │
   202     203
    │       │
   204     205
    │       │
    └───┬───┘
        │
       206
```

**Timeline**: 4 stages (2 parallel phases)

---

### Pattern 3: Deep Subtask Hierarchy

```
Epic #300: Multi-Provider Auth Refactoring
│
├── Task #301: Design auth provider abstraction (architect)
│   │
│   ├── Subtask #301.1: Research existing patterns
│   ├── Subtask #301.2: Design provider interface
│   └── Subtask #301.3: Document architecture decisions
│
├── Task #302: Implement core abstraction (build)
│   │
│   ├── Subtask #302.1: Create AuthProvider trait
│   ├── Subtask #302.2: Implement provider registry
│   └── Subtask #302.3: Add unit tests
│
└── Task #303: Implement OAuth provider (build)
    │
    ├── Subtask #303.1: Google OAuth integration
    ├── Subtask #303.2: GitHub OAuth integration
    └── Subtask #303.3: Provider tests
```

**When to use**: Very complex tasks that need progress tracking

---

### Pattern 4: Diamond Dependency

```
Epic #400: Database Migration
│
├── Task #401: Plan migration strategy (architect)
│   └── Status: done
│
├── Task #402: Migrate user data (build)
│   ├── Status: in-progress
│   └── Blocked by: 401
│
├── Task #403: Migrate product data (build)
│   ├── Status: in-progress
│   └── Blocked by: 401
│
└── Task #404: Verify data integrity (test)
    ├── Status: backlog
    └── Blocked by: 402, 403
```

**Dependency Flow** (Diamond):

```
       401
        │
    ┌───┴───┐
   402     403
    │       │
    └───┬───┘
        │
       404
```

**Use case**: Multiple parallel branches converge to final step

---

### Pattern 5: Fan-out (No Fan-in)

```
Epic #500: Code Quality Improvements
│
├── Task #501: Run code quality analysis (review)
│   └── Status: done
│
├── Task #502: Fix linting errors in auth module (fix)
│   ├── Status: ready
│   └── Blocked by: 501
│
├── Task #503: Fix linting errors in API module (fix)
│   ├── Status: ready
│   └── Blocked by: 501
│
├── Task #504: Fix linting errors in DB module (fix)
│   ├── Status: ready
│   └── Blocked by: 501
│
└── Task #505: Refactor deprecated patterns (refactor)
    ├── Status: ready
    └── Blocked by: 501
```

**Dependency Flow**:

```
       501
        │
    ┌───┼───┬───┐
   502 503 504 505
```

**Use case**: One analysis task spawns multiple independent fixes

---

## Dependency Types Explained

### 1. Blocking Dependency (`--blocks`)

**Purpose**: Task A must complete before Task B can start

**Visual representation**:

```
Task A [done] ──blocks──> Task B [ready]
Task A [in-progress] ──blocks──> Task B [backlog]
```

**Command**:

```bash
bd dep add 101 --blocks 102
```

**Effect**:

- Task #102 stays in `backlog` status
- When #101 moves to `done`, #102 automatically becomes `ready`
- Hard dependency - enforces ordering

**When to use**:

- Design must complete before implementation
- Implementation before testing
- Testing before documentation
- Fix before verification

---

### 2. Related Dependency (`--related`)

**Purpose**: Tasks are connected but can work in parallel

**Visual representation**:

```
Task A [in-progress] ~~related~~ Task B [in-progress]
```

**Command**:

```bash
bd dep add 102 --related 103
```

**Effect**:

- No status changes
- Informational link only
- Helps agents understand context
- Both tasks can be `in-progress` simultaneously

**When to use**:

- Security review alongside implementation
- Documentation alongside development
- Two implementations of same feature
- Parallel refactoring of related modules

---

### 3. Parent-Child (Epic) Relationship

**Purpose**: Group subtasks under an epic

**Visual representation**:

```
Epic #100
├── Task #101 (child)
├── Task #102 (child)
└── Task #103 (child)
```

**Command**:

```bash
bd create "Subtask title" --epic 100
```

**Effect**:

- Subtasks appear under epic in `bd show 100`
- Epic completion tracks subtask status
- Epic can't close until all subtasks done
- Hierarchical organization

**When to use**:

- Any complex feature (3+ tasks)
- Multi-agent coordination
- Phased projects
- Large refactorings

---

## Common Dependency Anti-Patterns

### ❌ Anti-Pattern 1: Over-Blocking

**Bad**:

```
Design ──blocks──> Implementation
Design ──blocks──> Security Review
Design ──blocks──> Documentation
```

**Why bad**: Security review and docs could start alongside implementation

**Good**:

```
Design ──blocks──> Implementation
Implementation ──blocks──> Security Review
Implementation ──blocks──> Documentation
```

Or better (parallel):

```
Design ──blocks──> Implementation
Implementation ──blocks──┬──> Security Review ──blocks──> Final Docs
                         └──> Initial Docs (can update later)
```

---

### ❌ Anti-Pattern 2: Circular Dependencies

**Bad**:

```
Task A ──blocks──> Task B
Task B ──blocks──> Task C
Task C ──blocks──> Task A  # Circular!
```

**Why bad**: Nothing can ever become `ready`

**Fix**: Identify actual ordering and break cycle

---

### ❌ Anti-Pattern 3: Missing Dependencies

**Bad**:

```
Epic: Add Feature
├── Design (no dependencies)
├── Implementation (no dependencies)
└── Testing (no dependencies)
```

**Why bad**: Implementation might start before design, tests before implementation

**Good**:

```
Epic: Add Feature
├── Design
├── Implementation (blocked by Design)
└── Testing (blocked by Implementation)
```

---

### ❌ Anti-Pattern 4: Epic as a Catch-All

**Bad**:

```
Epic: Miscellaneous Work Q1 2026
├── Fix bug #1
├── Add feature X
├── Refactor module Y
├── Update docs for Z
└── ... 50+ unrelated tasks
```

**Why bad**: Epic has no cohesion, doesn't track meaningful progress

**Good**: Create focused epics:

```
Epic: Authentication Improvements Q1 2026
├── Fix OAuth token refresh bug
├── Add 2FA support
├── Security audit
└── Update auth documentation
```

---

## Task Organization Decision Tree

```
                     New Work Item
                          │
                          ├─ Can 1 agent complete in <2 hours?
                          │
                    ┌─────┴─────┐
                   Yes           No
                    │             │
            Standalone Task    Is it part of larger effort?
            (bd create ...)     │
                          ┌─────┴─────┐
                         Yes           No
                          │             │
                   Subtask of Epic   Create Epic
                   (--epic N)        (--tag epic)
                                          │
                                    Break into subtasks
                                    (bd create ... --epic N)
                                          │
                                    Add dependencies
                                    (bd dep add ...)
```

---

## Hierarchy Best Practices

### 1. Epic Sizing

**Good epic size**: 3-10 subtasks, completable in 1-7 days

**Too small**: <3 subtasks → just use related tasks
**Too large**: >15 subtasks → split into multiple epics

---

### 2. Task Granularity

**Good task size**: 30 minutes - 3 hours of work

**Too small**: <15 minutes → combine with other micro-tasks
**Too large**: >4 hours → break into subtasks

---

### 3. Dependency Depth

**Good depth**: 1-3 levels of dependencies

**Too shallow**: No dependencies → missing coordination opportunities
**Too deep**: >5 levels → re-think architecture, simplify

---

### 4. Parallel Opportunities

**Identify parallelizable work**:

```
# Instead of:
A → B → C → D → E  (serial, 5 stages)

# Try:
    A
    ├─→ B ─┐
    └─→ C ─┼─→ E
        D ─┘
(parallel, 3 stages)
```

**Rule**: If tasks don't share direct dependencies, they can run in parallel.

---

## Visual Dependency Patterns Library

### Pattern: Linear Chain

```
A → B → C → D

Use case: Strict ordering required
Example: Design → Implement → Test → Deploy
```

---

### Pattern: Parallel Split

```
    A
    ├─→ B
    ├─→ C
    └─→ D

Use case: Independent work after initial task
Example: Research → (Feature 1, Feature 2, Feature 3)
```

---

### Pattern: Diamond (Fan-out/Fan-in)

```
       A
    ┌──┴──┐
    B     C
    └──┬──┘
       D

Use case: Parallel work that must integrate
Example: Design → (Frontend, Backend) → Integration Test
```

---

### Pattern: Multi-Stage Pipeline

```
A → B → C
    └─→ D → E

Use case: Pipeline with branch
Example: Design → Implement → (Deploy, Create Docs → Review)
```

---

### Pattern: Star (Hub and Spokes)

```
       A
    ┌──┼──┬──┐
    B  C  D  E

Use case: Central task spawns independent work
Example: Code Review → (Fix 1, Fix 2, Fix 3, Fix 4)
```

---

## Quick Reference: When to Use What

| Scenario                           | Use                        | Don't Use                      |
| ---------------------------------- | -------------------------- | ------------------------------ |
| Feature needs 5+ agents            | Epic with subtasks         | Flat task list                 |
| Task takes 4+ hours                | Break into subtasks        | Single giant task              |
| Work must happen in order          | `--blocks` dependency      | Hope agents figure it out      |
| Work can happen in parallel        | `--related` or independent | `--blocks` (over-constraining) |
| Tasks share context                | `--related`                | No links                       |
| One task requires another's output | `--blocks`                 | `--related`                    |
| Tracking multi-week project        | Epic with milestones       | Single task                    |
| Quick bug fix                      | Standalone task            | Unnecessary epic               |

---

## Task Lifecycle by Hierarchy Level

### Epic Lifecycle

```
1. CREATE     → Orchestrator creates epic
2. POPULATE   → Orchestrator creates subtasks
3. DELEGATE   → Subtasks assigned to agents
4. MONITOR    → Track subtask completion
5. VERIFY     → Review epic as whole
6. CLOSE      → Archive epic and subtasks
```

### Task Lifecycle

```
1. CREATE     → Part of epic or standalone
2. READY      → Becomes unblocked
3. ASSIGN     → Agent picks up work
4. WORK       → Agent executes
5. DONE       → Agent completes
6. VERIFY     → Review/validate
7. CLOSE      → Archive
```

### Subtask Lifecycle

```
1. CREATE     → Break down parent task
2. EXECUTE    → Often same agent as parent
3. DONE       → Quick completion
4. AGGREGATE  → Contributes to parent completion
```

---

## Conclusion

**Key Principles**:

1. **Use epics for coordination**: Complex work = epic + subtasks
2. **Keep tasks atomic**: One agent, one session, one outcome
3. **Block only when necessary**: Prefer parallel over serial
4. **Visualize dependencies**: Draw them out before implementing
5. **Flatten when possible**: Don't create hierarchy for hierarchy's sake

**Remember**: The hierarchy exists to **coordinate agents**, not to satisfy organizational process. Keep it as simple as possible while maintaining clarity.

---

**Next**: See [BEADS_EXAMPLES.md](./BEADS_EXAMPLES.md) for real-world scenarios and [BEADS_WORKFLOWS.md](./BEADS_WORKFLOWS.md) for agent-specific workflows.
