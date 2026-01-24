# Quick Start: Enable Parallel Agent Execution

This guide provides step-by-step instructions to enable aggressive parallel execution and delegation in your OpenCode setup.

## 5-Minute Implementation

### Step 1: Update Orchestrator Prompt

**File**: `prompts/orchestrator.txt`

Add this section after line 37 (after "Optimize for speed and quality"):

```
SUBAGENT INVOCATION WITH TASK TOOL:

The "task" tool is your gateway to parallel execution:

task.invoke({
  agents: [
    { agent: "agent_name_1", task: "Task A" },
    { agent: "agent_name_2", task: "Task B" },
    { agent: "agent_name_3", task: "Task C" }
  ],
  parallel: true,
  max_concurrent: 4
})

WHEN TO PARALLELIZE:
- Document (API) || Document (User Guide) || Document (Architecture)
- Review (Security) || Review (Performance) || Review (Code Quality)
- Test (Unit) || Test (Integration) || Test (Edge Cases)

YOUR TARGET: 80% delegation, 20% direct work.
Orchestrate, don't implement. Coordinate, don't do.
```

### Step 2: Update Build Prompt

**File**: `prompts/build.txt`

Replace entire content with:

```
You are the BUILD agent - specialized code implementation expert.

CORE RESPONSIBILITIES:
- Write production-quality code
- Implement features with error handling
- Follow project patterns and conventions
- DELEGATE specialized work to subagents

MANDATORY DELEGATION:
1. Testing → Test Agent ("Please write comprehensive tests")
2. Code Quality → Review Agent ("Please review this code")
3. Security → Security Agent ("Please analyze for vulnerabilities")
4. Performance → Optimize Agent ("Please optimize this")
5. Documentation → Document Agent ("Please write documentation")

YOUR WORKFLOW:
1. Implement feature incrementally
2. Delegate to Test for comprehensive test coverage
3. Delegate to Review for quality checks
4. Delegate to Security for security analysis
5. Delegate to Document for documentation

CRITICAL PRINCIPLE:
You write code. Specialists handle testing, review, security, docs.
Don't do their jobs. You're the implementer, not the QA/reviewer.

When in doubt: Is there a specialist for this?
- YES → Delegate
- NO → Do it yourself

Build it right. Use your specialists.
```

### Step 3: Add Settings

**File**: `.opencode.json` - Update the `settings` section (lines 300-305)

Replace:

```json
"settings": {
  "auto_invoke_architect": true,
  "auto_review_before_commit": true,
  "parallel_subagents": true,
  "max_parallel_agents": 4
}
```

With:

```json
"settings": {
  "auto_invoke_architect": true,
  "auto_review_before_commit": true,
  "parallel_subagents": true,
  "max_parallel_agents": 4,

  "orchestrator": {
    "prefer_delegation": true,
    "delegation_target": "80%",
    "aggressive_parallelization": true
  },

  "build_agent": {
    "delegates_testing": true,
    "delegates_review": true,
    "delegates_security": true,
    "delegates_documentation": true
  }
}
```

### Step 4: Test It

Run a complex task with the orchestrator:

```bash
opencode --agent orchestrator "Implement a new API endpoint with tests, security review, and documentation"
```

Expected behavior:

- Orchestrator creates a plan
- Delegates testing, security, and documentation in parallel
- Returns comprehensive results

---

## What Changes

### Before (Sequential)

```
Orchestrator → thinks → sequential workflow
  1. Architect designs
  2. Build implements
  3. Test tests (if it happens)
  4. Review reviews (if it happens)
  5. Document documents (rarely)
```

**Result**: 1-2 hours for a complete feature

### After (Parallel)

```
Orchestrator → orchestrates → parallel execution
  1. Architect designs
  [Then in parallel]
  2. Build implements        3. Plan breaks down edge cases
  [Then in parallel]
  4. Test writes tests       5. Document writes docs       6. Security analyzes
  [Then in parallel]
  7. Review checks code      8. Optimize performance

  Results synthesized → complete feature
```

**Result**: 30-45 minutes for a complete feature (2-4x faster)

---

## Key Changes Explained

### 1. The "task" Tool

- **What**: Mechanism for orchestrator to invoke subagents
- **Where**: Only available to orchestrator (`"task": true` in config)
- **Why**: Enables parallel execution
- **How**: `task.invoke({ agents: [...], parallel: true })`

### 2. Delegation Framework

- Build agent now actively delegates to specialists
- Reduces build agent workload from 100% to 20%
- Specialists handle their domains better than generalists

### 3. Parallel Settings

- Signals to orchestrator that parallelization is encouraged
- Provides explicit configuration for delegation behavior
- Makes orchestrator more aggressive about using subagents

---

## Validation

After implementing, check:

```bash
# Test 1: Complex multi-step task
opencode --agent orchestrator "Complex task with multiple independent subtasks"
# Expected: Orchestrator mentions using multiple agents in parallel

# Test 2: Build delegation
opencode --agent build "Implement authentication system"
# Expected: Build mentions delegating testing and security review

# Test 3: Monitor execution
# Expected: Multiple agents working simultaneously (check in logs/UI)
```

---

## Optional Enhancements

### Add Parallel Workflow (Advanced)

Add to `.opencode.json` `workflows` section:

```json
"feature-development-fast": {
  "description": "Fast parallel feature development",
  "orchestrator": true,
  "steps": [
    {
      "phase": "design",
      "steps": [
        { "agent": "architect", "task": "Design feature" }
      ]
    },
    {
      "phase": "parallel_dev",
      "parallel": true,
      "steps": [
        { "agent": "build", "task": "Implement core feature" },
        { "agent": "test", "task": "Plan test strategy" },
        { "agent": "document", "task": "Plan documentation" }
      ]
    },
    {
      "phase": "parallel_qa",
      "parallel": true,
      "steps": [
        { "agent": "test", "task": "Write comprehensive tests" },
        { "agent": "security", "task": "Security analysis" },
        { "agent": "review", "task": "Code review" }
      ]
    },
    {
      "phase": "finalize",
      "steps": [
        { "agent": "document", "task": "Finalize documentation" }
      ]
    }
  ]
}
```

### Update Architect Prompt

Add to `prompts/architect.txt` after line 25:

```
DELEGATION TO PLANNING:
For complex features:
1. Design the architecture
2. Delegate task breakdown to Plan agent
3. Plan agent creates parallelizable subtasks
4. Hand off to Build and subagents

Working with Plan Agent:
- Plan is your fast task breakdown specialist (Haiku model)
- Use it to identify parallelizable work
- Leverage it to structure complex features
```

---

## Troubleshooting

### Agents Still Sequential?

**Cause**: Prompt hasn't taken effect or orchestrator isn't using task tool
**Fix**:

1. Verify prompt was updated
2. Restart OpenCode
3. Try explicit orchestrator invocation

### Build Agent Not Delegating?

**Cause**: Prompt change not applied
**Fix**:

1. Check `prompts/build.txt` was updated
2. Verify settings include delegation config
3. Test with explicit delegation request

### Configuration Not Applied?

**Cause**: JSON syntax error in `.opencode.json`
**Fix**:

1. Validate JSON: `cat .opencode.json | jq empty`
2. Check for trailing commas
3. Ensure proper nesting

---

## Next Steps

1. ✅ Implement the 3 changes above
2. ✅ Test with a complex task
3. ✅ Monitor execution (check logs)
4. ✅ Iterate on prompts based on results
5. ✅ Add optional enhancements as needed

---

## Performance Impact

**Expected improvements:**

| Metric                   | Before        | After           | Improvement            |
| ------------------------ | ------------- | --------------- | ---------------------- |
| Time to complete feature | 60-120 min    | 15-45 min       | 2-4x faster            |
| Code quality             | Good          | Better          | +20-30% (more reviews) |
| Test coverage            | Partial       | Comprehensive   | More complete          |
| Security review          | Manual        | Automatic       | Always included        |
| Documentation            | Often missing | Always included | 100% coverage          |

---

## Files Modified

- ✅ `prompts/orchestrator.txt` - Add parallel invocation guidance
- ✅ `prompts/build.txt` - Add delegation requirements
- ✅ `.opencode.json` - Add parallelism settings
- ⭐ `prompts/architect.txt` - (Optional) Add plan delegation

---

**Important**: After making changes, restart OpenCode for changes to take effect.

For detailed information, see `docs/OPENCODE-PARALLEL-CONFIGURATION.md`
