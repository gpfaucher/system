# Agent Orchestration: Quick Implementation Guide

**Priority**: P0 (Critical)  
**Estimated Effort**: 4-6 hours total  
**Impact**: 30% efficiency improvement  

---

## THE PROBLEM (In 60 Seconds)

Your agent system has 3 critical issues:

1. **Orchestrator Implements** (Should only coordinate)
   - No enforcement of delegation rule
   - Missing pre-action checklist
   
2. **Wrong Agents Get Used** (Should use specialists)
   - No mandatory agent paths
   - Generic agent absorbs specialized work
   
3. **Agents Get Stuck** (Should break large tasks)
   - No task size limits defined
   - No guidance on subtask creation

---

## THE SOLUTION (3 Simple Changes)

### 1. Add Orchestrator Enforcement (30 min)

**File**: `prompts/orchestrator.txt`

**Add before line 15**:
```
CRITICAL CONSTRAINT: DELEGATION ENFORCEMENT

BEFORE taking ANY action:
□ Can a specialist agent handle this?
  YES → Delegate immediately
  NO  → Ask user

FORBIDDEN:
- Write code (→ Build)
- Write tests (→ Test)
- Write docs (→ Document)
- Run long processes (→ Async)

If you would break this: Create task, delegate, synthesize result.
```

### 2. Add Mandatory Agent Paths (45 min)

**File**: `prompts/orchestrator.txt`

**Add new section "MANDATORY AGENT PATHS"**:
```
NEW FEATURE:
  Architect (design) [REQUIRED]
  → Build (implement) [REQUIRED]
  → Test + Review + Security [PARALLEL]
  → Document [REQUIRED]

BUG FIX:
  Simple → Fix (fast)
  Complex → Debug → Fix

SECURITY:
  Security (audit first) [MANDATORY]
  → Fix/Build (remediate)
  → Review (verify)

NIXOS:
  Architect → Nix-Specialist → Security → Review
```

### 3. Add Task Sizing Rules (45 min)

**Files**: `prompts/orchestrator.txt`, `prompts/build.txt`, `prompts/test.txt`

**Add to orchestrator.txt**:
```
TASK SIZING (MUST FOLLOW):

Haiku (Plan, Research, Fix, Explore):
  MAX: 2-3 minutes per task

Sonnet (Build, Test, Debug, etc.):
  MAX: 5-10 minutes per subtask

IF TASK > SIZE LIMIT:
  Split into smaller subtasks
  Create separate Beads tasks
  Run in sequence or parallel
```

**Add to build.txt after WORKFLOW**:
```
TASK SIZING:
Your task should be 5-10 minutes.
If would take longer:
  - STOP and create subtasks
  - Mark current portion done
  - Create new task for rest
```

---

## QUICK IMPLEMENTATION CHECKLIST

### Phase 1: Update Prompts (2 hours)

- [ ] **orchestrator.txt** (1.5 hours)
  - [ ] Add enforcement section (line 10)
  - [ ] Add mandatory paths section
  - [ ] Add task sizing section
  - [ ] Add decision checklist

- [ ] **build.txt** (15 min)
  - [ ] Add task sizing after WORKFLOW

- [ ] **AGENTS.md** (30 min)
  - [ ] Add "Orchestration Principles" section
  - [ ] Add "Mandatory Agent Paths" section
  - [ ] Add "Task Sizing Guidelines" section

### Phase 2: Test (1-2 hours)

- [ ] Request a new feature
- [ ] Verify Orchestrator creates epic
- [ ] Check Architect designs first
- [ ] Confirm Build implements
- [ ] Verify Test/Review run after
- [ ] Check Document happens last

### Phase 3: Iterate (1 hour)

- [ ] Monitor for stuck agents
- [ ] Adjust sizing rules if needed
- [ ] Refine mandatory paths based on real work

---

## KEY DECISION MATRIX

Use this to route work:

| Work Type | Agent | Why | Note |
|-----------|-------|-----|------|
| New Feature | Architect→Build→Test→Review→Doc | Mandatory sequence | Never skip |
| Simple Bug | Fix | Fast (Haiku) | Typos, config |
| Complex Bug | Debug→Fix→Test | Root cause first | Unknown cause |
| Testing | Test | Specialist | TDD or verification |
| Docs | Document | Specialist | Never skip |
| Security | Security (FIRST) | Mandatory audit | Audit before fix |
| Refactor | Refactor | Specialist | Structure improvement |
| Performance | Optimize | Specialist | Must measure first |
| NixOS | Nix-Specialist | Expertise required | System config |
| Planning | Plan | Fast (Haiku) | Task breakdown |
| Research | Research | Fast (Haiku) | Deep analysis |
| Explore | Explore | Fast (Haiku) | Quick find |
| Misc | General | Fallback only | Last resort |

---

## ANTI-PATTERNS TO FIX

### ❌ BEFORE

```
User: "Build export feature"
Orchestrator: [Designs → Implements → Tests → Documents]
Result: One long monolithic response, context exhaustion, mistakes
```

### ✅ AFTER

```
User: "Build export feature"
Orchestrator: 
  [Analyzes request]
  → "I'll coordinate this multi-agent work"
  → bd create "Epic: Export feature"
  → bd create "Design export" --assign architect
  → bd create "Implement export" --epic 123 --assign build
  → bd create "Test export" --epic 123 --assign test
  → bd create "Document export" --epic 123 --assign document
  → [Launches architect, waits for design]
  → [Launches build, waits for implementation]
  → [Launches test and review in parallel]
  → [Launches document]
  → [Synthesizes results]
Result: Coordinated multi-agent workflow, parallel execution, clear checkpoints
```

---

## FILE CHANGES SUMMARY

### Files to Modify

1. **prompts/orchestrator.txt** (+~80 lines)
   - Add enforcement section
   - Add mandatory paths
   - Add task sizing
   - Add decision checklist

2. **prompts/build.txt** (+~10 lines)
   - Add task sizing after WORKFLOW

3. **prompts/test.txt** (+~10 lines)
   - Add checkpoint pattern

4. **AGENTS.md** (+~100 lines)
   - Add orchestration principles
   - Add mandatory paths
   - Add task sizing

5. **.opencode.json** (No changes required initially)
   - Review if needed later

---

## VALIDATION CHECKLIST

After implementing, verify:

- [ ] Orchestrator creates epic for multi-agent work
- [ ] Orchestrator delegates to specialists
- [ ] Architect always designs before Build implements
- [ ] Test/Review run after Build
- [ ] Large tasks are automatically broken into subtasks
- [ ] Stuck agents decrease (monitor task duration)
- [ ] Beads tasks created and tracked properly
- [ ] No "doing everything myself" in orchestrator responses

---

## EXPECTED RESULTS

**Before**:
- Orchestrator delegation: ~70%
- Wrong agent usage: Common
- Stuck agents: Frequent
- Context efficiency: ~60%

**After** (within 2 weeks):
- Orchestrator delegation: ≥95%
- Wrong agent usage: Rare
- Stuck agents: Rare
- Context efficiency: ≥90%
- Delivery speed: ~30% faster

---

## NEXT STEPS

1. **TODAY**: Implement prompt changes (2 hours)
2. **TOMORROW**: Test with real requests (1-2 hours)
3. **THIS WEEK**: Monitor and adjust (1 hour)
4. **NEXT WEEK**: Full validation (ongoing)

---

**Full Research**: See `AGENT-ORCHESTRATION-RESEARCH.md`  
**Decision Support**: See AGENT-GUIDE.md for per-agent info  
**Task Tracking**: Use `bd` commands for persistent memory  

---

_Quick guide prepared: 2026-01-24_  
_Full research available in docs/AGENT-ORCHESTRATION-RESEARCH.md_
