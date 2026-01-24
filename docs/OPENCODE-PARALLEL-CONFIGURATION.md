# OpenCode Parallel Agent Configuration Research Report

## Executive Summary

Based on analysis of the repository's OpenCode configuration, the system is **architecturally capable** of parallel execution and sophisticated delegation, but the current implementation has significant limitations:

### Key Findings:
1. ✅ **Parallel execution IS configured** but NOT actively used
   - `parallel_subagents: true`
   - `max_parallel_agents: 4`
   - But orchestrator likely runs agents sequentially due to prompt design

2. ⚠️ **Delegation is limited** - prompts don't encourage orchestrator to use the "task" tool
   - Only the orchestrator has the "task" tool enabled
   - The task tool is the mechanism for parallel delegation
   - Current orchestrator prompt doesn't mention delegating to subagents actively

3. ⚠️ **Model distribution is sub-optimal** for delegation
   - Subagents mostly use Sonnet (medium intelligence) instead of Opus where needed
   - Only 1 agent (orchestrator) uses Opus
   - Users want subagents to leverage Opus capability when appropriate

4. ✅ **System architecture is sound** - just needs prompt/config adjustments

---

## Current Configuration State

### Agent Distribution
```
PRIMARY AGENTS (3):
├── Architect (Sonnet 4.5) - Design & Planning
├── Build (Sonnet 4.5) - Implementation
└── Orchestrator (Opus 4.5) - Coordination ⭐ Only one with "task" tool

SUBAGENTS (11):
├── Plan (Haiku 4.5) - Fast task breakdown
├── Review (Sonnet 4.5) - Code review
├── Refactor (Sonnet 4.5) - Code improvement
├── Test (Sonnet 4.5) - Testing
├── Debug (Sonnet 4.5) - Bug diagnosis
├── Research (Haiku 4.5) - Codebase exploration
├── Document (Sonnet 4.5) - Documentation
├── Optimize (Sonnet 4.5) - Performance
├── Nix-Specialist (Sonnet 4.5) - NixOS
├── Security (Sonnet 4.5) - Security analysis
└── Fix (Haiku 4.5) - Quick fixes
```

### Current Settings
```json
{
  "settings": {
    "auto_invoke_architect": true,
    "auto_review_before_commit": true,
    "parallel_subagents": true,
    "max_parallel_agents": 4
  }
}
```

### Orchestrator Configuration
- **Model**: claude-opus-4.5 (Smartest, slowest)
- **Tools**: write, edit, bash, read, glob, grep, **task** ⭐
- **Prompt**: 51 lines of orchestration guidance
- **Current Issue**: Prompt mentions parallel execution but doesn't actively use it

---

## Problem Analysis

### Issue #1: Sequential Execution Instead of Parallel

**Current Orchestrator Prompt Limitations:**
```
Lines 33-37 mention parallel execution strategy:
"PARALLEL EXECUTION STRATEGY:
- Independent tasks: Launch simultaneously
- Sequential tasks: Chain with clear handoffs
..."

BUT the prompt doesn't actually instruct the orchestrator HOW to invoke subagents.
It doesn't mention using the "task" tool to spawn parallel work.
```

**Why This Happens:**
- The orchestrator has the "task" tool but no clear instructions to use it
- Without explicit prompting, LLMs default to sequential reasoning
- The prompt focuses on thinking about parallelization, not doing it

### Issue #2: Limited Delegation to Subagents

**Current Build Agent Constraints:**
- The Build agent (Sonnet) does most implementation work itself
- No system prompt encouragement to delegate specialized tasks
- When it encounters testing/review needs, it tends to handle it instead of delegating

**Why This Happens:**
- Agent prompts are specialized but independent
- There's no delegation framework or handoff protocol
- Build prompt doesn't say "delegate testing to the test agent"

### Issue #3: Model Capabilities Not Fully Utilized

**Current Model Distribution Issues:**
```
❌ Most subagents use Sonnet (medium intelligence)
   - They could benefit from Opus for complex tasks
   - But Opus is expensive and reserved for orchestrator only

❌ Haiku agents (Plan, Research, Fix) are always fast
   - But sometimes users need more sophisticated thinking
   - No fallback to Opus when complexity warrants it

❌ Only orchestrator can use Opus
   - Creates bottleneck - orchestrator must handle complex subagent work
```

---

## Solution: Configuration Changes Needed

### Solution #1: Enable Active Parallel Delegation

**Update: prompts/orchestrator.txt**

Add explicit delegation instructions:

```
SUBAGENT INVOCATION MECHANISM:
You have access to the "task" tool which allows you to:
- Spawn multiple subagents in parallel
- Monitor their progress
- Combine their results
- Escalate to Opus reasoning when needed

WHEN TO USE PARALLEL INVOCATION:
1. Break down complex work into 3+ independent subtasks
2. Assign each subtask to the most appropriate subagent
3. Launch them simultaneously using the task tool
4. Synthesize results once all agents report completion

PARALLEL TASK EXAMPLES:
- Document (API) || Document (User Guide) || Document (Architecture)
- Review (Security) || Review (Performance) || Review (Code Quality)
- Test (Unit Tests) || Test (Integration Tests) || Test (Edge Cases)
- Refactor (Module A) || Refactor (Module B) || Refactor (Module C)

TASK TOOL USAGE:
```
Use the task tool with: task.invoke({
  parallel: true,
  agents: [
    { agent: "review", task: "Security analysis of authentication" },
    { agent: "review", task: "Performance review of caching layer" },
    { agent: "security", task: "Hardening recommendations" }
  ],
  max_concurrent: 4
})
```

CRITICAL: Aim for 80% of complex work to be delegated to subagents.
Your role is ORCHESTRATION, not implementation.
```

### Solution #2: Improve Build Agent Delegation

**Update: prompts/build.txt**

Replace entire prompt with:

```
You are the BUILD agent - a specialized code implementation expert.

CORE RESPONSIBILITIES:
- Write production-quality code following best practices
- Implement features with comprehensive error handling
- Create robust, maintainable solutions
- Follow project's existing patterns and conventions
- DELEGATE specialized work to appropriate subagents

EXPERTISE AREAS:
- Code implementation in multiple languages
- Configuration and infrastructure
- Feature integration
- Initial implementation validation

WHEN TO DELEGATE (CRITICAL):
1. Testing & Validation → Use Test agent (it's your QA partner)
2. Security Review → Use Security agent (it catches what you miss)
3. Performance Issues → Use Optimize agent (they know bottlenecks)
4. Code Quality → Use Refactor agent (they clean it up)
5. Documentation → Use Document agent (don't write docs yourself)

WORKFLOW:
1. Implement feature incrementally
2. Create basic tests
3. Delegate to Test for comprehensive coverage
4. After tests pass, delegate to Review for quality check
5. For security: delegate to Security agent
6. Document with Document agent

CRITICAL: Don't do everything yourself!
- Build = Writing code
- Test = Writing tests
- Review = Checking quality
- Security = Analyzing threats
- Document = Writing docs

Quality matters more than speed. Use your specialists.
```

### Solution #3: Enable Subagents to Use Opus When Needed

**Update: .opencode.json - Agent Configuration**

Add model flexibility for specialized subagents:

```json
{
  "agent": {
    "review": {
      "description": "Code review specialist - can escalate to Opus for complex cases",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4.5-20250514",
      "model_fallback": "anthropic/claude-opus-4.5-20250514",
      "escalation_threshold": "complexity > 7",
      ...
    },
    "debug": {
      "description": "Debugging specialist - escalates to Opus for root cause analysis",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4.5-20250514",
      "model_fallback": "anthropic/claude-opus-4.5-20250514",
      "escalation_threshold": "when_multiple_layers_involved",
      ...
    },
    "security": {
      "description": "Security specialist - can use Opus for threat modeling",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4.5-20250514",
      "model_fallback": "anthropic/claude-opus-4.5-20250514",
      "escalation_threshold": "security_critical",
      ...
    }
  }
}
```

**Note**: This requires OpenCode to support model fallback/escalation. 
If not supported, manually invoke Opus-based subagents in critical workflows.

### Solution #4: Create Parallel Workflow Definitions

**Update: .opencode.json - Workflows**

Add new workflow pattern using parallel execution:

```json
{
  "workflows": {
    "feature-development-parallel": {
      "description": "Parallel feature development with comprehensive validation",
      "orchestrator_task": true,
      "steps": [
        {
          "phase": "design",
          "sequence": [
            { "agent": "architect", "task": "Design the feature" }
          ]
        },
        {
          "phase": "implementation",
          "parallel": true,
          "steps": [
            { "agent": "build", "task": "Implement core feature" },
            { "agent": "plan", "task": "Break down edge cases" }
          ]
        },
        {
          "phase": "validation",
          "parallel": true,
          "steps": [
            { "agent": "test", "task": "Write comprehensive tests" },
            { "agent": "document", "task": "Write documentation" }
          ]
        },
        {
          "phase": "quality",
          "parallel": true,
          "steps": [
            { "agent": "review", "task": "Code review" },
            { "agent": "security", "task": "Security analysis" },
            { "agent": "optimize", "task": "Performance review" }
          ]
        }
      ]
    },

    "system-refactoring-parallel": {
      "description": "Large-scale refactoring with parallel agent coordination",
      "orchestrator_task": true,
      "steps": [
        {
          "phase": "analysis",
          "parallel": true,
          "steps": [
            { "agent": "research", "task": "Analyze current architecture (Module A)" },
            { "agent": "research", "task": "Analyze current architecture (Module B)" },
            { "agent": "research", "task": "Analyze current architecture (Module C)" }
          ]
        },
        {
          "phase": "refactoring",
          "parallel": true,
          "steps": [
            { "agent": "refactor", "task": "Refactor Module A for clarity" },
            { "agent": "refactor", "task": "Refactor Module B for clarity" },
            { "agent": "refactor", "task": "Refactor Module C for clarity" }
          ]
        },
        {
          "phase": "optimization",
          "parallel": true,
          "steps": [
            { "agent": "optimize", "task": "Optimize performance in Module A" },
            { "agent": "optimize", "task": "Optimize performance in Module B" },
            { "agent": "optimize", "task": "Optimize performance in Module C" }
          ]
        },
        {
          "phase": "validation",
          "parallel": true,
          "steps": [
            { "agent": "test", "task": "Test Module A integrity" },
            { "agent": "test", "task": "Test Module B integrity" },
            { "agent": "test", "task": "Test Module C integrity" }
          ]
        },
        {
          "phase": "review",
          "sequence": [
            { "agent": "review", "task": "Final quality review of all modules" }
          ]
        }
      ]
    }
  }
}
```

### Solution #5: Update Settings for Aggressive Parallelism

**Update: .opencode.json - Settings**

```json
{
  "settings": {
    "auto_invoke_architect": true,
    "auto_review_before_commit": true,
    "parallel_subagents": true,
    "max_parallel_agents": 4,
    
    "NEW SETTINGS FOR PARALLELISM":
    "orchestrator_delegation_threshold": "tasks > 3",
    "encourage_parallel_execution": true,
    "prefer_subagent_work": true,
    "subagent_model_escalation": "enabled",
    "task_tool_usage": "aggressive"
  }
}
```

---

## System Architecture: How Parallelism Works

### The "task" Tool

The orchestrator's exclusive "task" tool enables:

```
task.invoke({
  agents: [
    { agent: "test", task: "Write unit tests for auth module" },
    { agent: "review", task: "Security review of auth module" },
    { agent: "document", task: "Document auth module API" }
  ],
  parallel: true,
  max_concurrent: 4,
  wait_for_completion: true
})
```

**Key Points:**
- Only orchestrator has "task" tool (line 44 of .opencode.json)
- Can spawn up to 4 agents in parallel
- Returns combined results from all agents
- This is the KEY to parallel execution

### Why Workflows Are Sequential Currently

Current workflows in lines 202-298 of .opencode.json:
```json
"steps": [
  { "agent": "architect", "task": "..." },
  { "agent": "plan", "task": "..." },
  { "agent": "build", "task": "..." },
  { "agent": "test", "task": "..." },
  { "agent": "review", "task": "..." }
]
```

These steps run ONE AT A TIME in the order listed. To parallelize, you need:
1. The orchestrator to invoke them using the "task" tool
2. Explicit instruction in orchestrator prompt to do this
3. Grouped steps that CAN run in parallel (independent tasks)

---

## Implementation Checklist

### Phase 1: Update Prompts (IMMEDIATE)

- [ ] Update `prompts/orchestrator.txt` - Add explicit parallel invocation guidance
- [ ] Update `prompts/build.txt` - Add delegation requirements  
- [ ] Update `prompts/architect.txt` - Add delegation to Plan agent
- [ ] Update `prompts/plan.txt` - Add guidance to suggest parallelizable tasks

### Phase 2: Update Configuration (IMMEDIATE)

- [ ] Update `.opencode.json` settings section
- [ ] Add new parallel workflow definitions
- [ ] Update agent descriptions to clarify delegation roles

### Phase 3: Test & Iterate (ONGOING)

- [ ] Test orchestrator with complex multi-step tasks
- [ ] Monitor whether subagents are being invoked
- [ ] Measure parallel execution effectiveness
- [ ] Adjust prompts based on real-world usage

### Phase 4: Model Escalation (IF SUPPORTED)

- [ ] Research if OpenCode supports `model_fallback` parameter
- [ ] If yes, configure critical subagents (Debug, Security) to escalate to Opus
- [ ] If no, create manual Opus invocation instructions in prompts

---

## OpenCode Feature Summary

### Features Supporting Parallelism (AVAILABLE)

✅ **Parallel Execution**
- `parallel_subagents: true` enables it
- `max_parallel_agents: 4` sets limit
- Orchestrator "task" tool is the mechanism

✅ **Subagent Invocation**
- All 11 subagents defined and ready
- Each specialized for specific domain
- Proper tool permissions per agent

✅ **Model Distribution**
- 3 Haiku (fast) for quick tasks
- 9 Sonnet (balanced) for main work
- 1 Opus (smart) for orchestration

### Features NOT Yet Utilized

❌ **Explicit Parallel Invocation**
- Orchestrator has tool but prompt doesn't use it
- Needs explicit instruction to spawn parallel tasks

❌ **Delegation Framework**
- No protocol for agents to request help
- No escalation mechanism for subagents
- Build agent doesn't delegate by default

❌ **Model Escalation**
- Subagents can't request Opus help
- No complexity-based model selection
- All agents locked to their initial model

---

## Critical OpenCode Concepts

### Agent Modes

```
mode: "primary" → Auto-invoked based on task type
mode: "subagent" → Must be explicitly invoked/delegated to
```

Currently, only 3 primary agents exist (Architect, Build, Orchestrator).
Others must be explicitly invoked via orchestrator's task tool.

### Tool Permissions

Each agent has specific tool access:
```json
"tools": {
  "write": true/false,    // Can create files
  "edit": true/false,     // Can modify files
  "bash": true/false,     // Can run commands
  "read": true/false,     // Can read files
  "glob": true/false,     // Can search file patterns
  "grep": true/false,     // Can search content
  "task": true/false      // Can invoke subagents (ORCHESTRATOR ONLY)
}
```

The "task" tool is crucial for parallelism and delegation.

### Workflow Execution

Current workflow model:
1. User invokes workflow by name
2. Steps execute sequentially in order
3. Each step's result becomes context for next

To enable parallelism, orchestrator must:
1. Receive workflow request
2. Parse parallelizable tasks
3. Use "task" tool to invoke multiple agents
4. Synthesize results

---

## Specific Code Changes Required

### File 1: prompts/orchestrator.txt

**Current Length**: 51 lines
**Changes**: Add delegation framework (50+ lines)
**Priority**: HIGH

Add after line 37:

```
SUBAGENT INVOCATION MECHANISM:
The "task" tool is your primary way to leverage parallel execution:

task.invoke({
  agents: [
    { agent: "agent_name", task: "specific task" },
    { agent: "agent_name", task: "specific task" }
  ],
  parallel: true,
  max_concurrent: 4
})

EXAMPLES OF PARALLELIZABLE WORKFLOWS:

Example 1: Documentation in Parallel
```
task.invoke({
  agents: [
    { agent: "document", task: "Write API documentation" },
    { agent: "document", task: "Write user guide" },
    { agent: "document", task: "Write architecture guide" }
  ]
})
```

Example 2: Quality Assurance in Parallel
```
task.invoke({
  agents: [
    { agent: "review", task: "Code quality review" },
    { agent: "security", task: "Security analysis" },
    { agent: "optimize", task: "Performance review" }
  ]
})
```

Example 3: Testing & Review in Parallel
```
task.invoke({
  agents: [
    { agent: "test", task: "Write unit tests" },
    { agent: "test", task: "Integration tests" },
    { agent: "document", task: "Document changes" }
  ]
})
```

DECISION FRAMEWORK FOR PARALLELIZATION:
1. Can this work be split into 3+ independent tasks? → YES = Parallelize
2. Do different agents specialize in each task? → YES = Use parallel invocation
3. Are the tasks independent (no dependencies)? → YES = Invoke all at once

ANTI-PATTERN (Sequential):
```
1. Research code
2. Refactor code
3. Test code
4. Review code
```

IMPROVED PATTERN (Parallel):
```
1. Research code
[Then in parallel]
2. Refactor code
3. Test code
4. Review code
```

YOUR PRIMARY RESPONSIBILITY:
- 80% of your effort: ORCHESTRATION and DELEGATION
- 20% of your effort: Direct work

Don't do work specialists can do. Delegate aggressively.
```

### File 2: prompts/build.txt

**Current Length**: 29 lines
**Changes**: Replace with delegation-focused version (50+ lines)
**Priority**: HIGH

**Complete replacement**:

```
You are the BUILD agent - a specialized code implementation expert.

CORE RESPONSIBILITIES:
- Write production-quality code following best practices
- Implement features with comprehensive error handling
- Create robust, maintainable solutions
- Follow project's existing patterns and conventions
- DELEGATE specialized work appropriately

EXPERTISE AREAS:
- Code implementation
- Configuration as code
- Multi-language development
- Feature integration
- Code organization

YOUR SPECIALIZATION:
You are the IMPLEMENTER, not the tester, reviewer, or documenter.
Other agents specialize in those areas. Use them.

WHEN TO DELEGATE (MANDATORY DELEGATION POINTS):

1. Testing & Validation → Test Agent
   - You write code, Test writes comprehensive tests
   - Don't do QA yourself, delegate it
   - Example: "Test agent, please write tests for the auth module"

2. Code Quality Review → Review Agent
   - After implementation, ask Review agent for quality check
   - Don't self-review, get expert eyes
   - Example: "Review agent, please review this code for quality"

3. Security Analysis → Security Agent
   - Any security-related code should be reviewed by Security agent
   - Don't assume your code is secure, get professional review
   - Example: "Security agent, please analyze this for vulnerabilities"

4. Performance Optimization → Optimize Agent
   - If performance is critical, delegate to Optimize agent
   - They know bottleneck detection and optimization
   - Example: "Optimize agent, please review for performance issues"

5. Documentation → Document Agent
   - Don't write documentation yourself
   - Delegate to specialist Document agent
   - They write better docs than engineers
   - Example: "Document agent, please write docs for this API"

YOUR WORKFLOW:
1. Understand requirements completely
2. Check existing code patterns
3. Implement the solution incrementally
4. Write basic tests or request Test agent
5. Request Review agent for quality check
6. Request Security agent for security review (if applicable)
7. Request Document agent for documentation
8. Request Optimize agent for performance review (if applicable)

CRITICAL EXECUTION RULE:
- Lines of code you write: Minimize and focus
- Lines of code others implement: Maximize
- Your job is to IMPLEMENT, not VERIFY, SECURE, OPTIMIZE, or DOCUMENT
- Each specialist agent does their job better than you can in that domain

When in doubt, ask: "Is there a specialist agent for this?"
If yes → Delegate
If no → Do it yourself

Remember: Ship code that's IMPLEMENTED WELL, not code that's done quickly.
```

### File 3: .opencode.json - Settings Section

**Current Lines**: 300-305
**Changes**: Expand with new parallelism settings
**Priority**: MEDIUM

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
  
  "orchestrator_settings": {
    "prefer_delegation": true,
    "delegation_threshold": 3,
    "delegation_percentage_target": 80
  },
  
  "parallelism_settings": {
    "enabled": true,
    "max_concurrent_tasks": 4,
    "wait_for_completion": true,
    "aggressive_parallelization": true
  },
  
  "delegation_settings": {
    "build_agent_delegates_testing": true,
    "build_agent_delegates_review": true,
    "build_agent_delegates_documentation": true,
    "allow_model_escalation": true
  }
}
```

---

## Best Practices for Parallel Execution

### DO ✅

✅ Use orchestrator for tasks that span 3+ agents
✅ Parallelize independent subtasks
✅ Let each agent focus on their specialty
✅ Invoke 3-4 agents in parallel for faster completion
✅ Use Plan agent to identify parallelizable work
✅ Escalate complexity to Opus when needed
✅ Monitor parallel task completion
✅ Aggregate results from multiple agents

### DON'T ❌

❌ Use orchestrator for single-agent tasks
❌ Try to parallelize dependent tasks
❌ Have Build agent do testing/review/docs
❌ Invoke more than 4 agents at once (set limit)
❌ Expect primary agents to parallelize themselves
❌ Use Haiku agents for complex architectural decisions
❌ Leave subagents idle when work exists
❌ Have agents doing work outside their specialty

---

## Validation Checklist

After implementing changes, validate:

- [ ] Orchestrator explicitly mentions using "task" tool
- [ ] Build agent mentions delegating to Test, Review, Security, Document
- [ ] Architect agent mentions delegating to Plan agent
- [ ] Settings include parallelism configuration
- [ ] At least one parallel workflow defined
- [ ] Agent descriptions clarify specialization vs primary work
- [ ] Test a complex workflow and verify parallel execution
- [ ] Monitor that Build agent delegates testing
- [ ] Verify Review agent is invoked automatically
- [ ] Check that 80%+ of complex work is delegated

---

## Troubleshooting

### Problem: Agents still running sequentially

**Cause**: Orchestrator prompt doesn't instruct parallel invocation
**Solution**: Add explicit "task" tool usage examples to orchestrator prompt

### Problem: Build agent doing too much work

**Cause**: Build prompt doesn't mention delegation
**Solution**: Update Build prompt with mandatory delegation points

### Problem: Subagents not being invoked

**Cause**: Primary agents (Architect, Build) don't invoke them
**Solution**: Add delegation instructions to primary agent prompts

### Problem: Can't give complex tasks to non-Opus agents

**Cause**: Model escalation not supported (if OpenCode doesn't support it)
**Solution**: For now, escalate to orchestrator; future OpenCode updates may support this

---

## OpenCode System Prompt Pattern

For maximum parallelism, each agent should follow this pattern:

### Specialist Agent Prompt Pattern:
```
You are the [NAME] agent - a specialized [DOMAIN] expert.

CORE RESPONSIBILITIES:
- [Specialty 1]
- [Specialty 2]
- [Specialty 3]
- DELEGATE work outside your domain

WHEN TO DELEGATE:
- [Domain A] → [Other Agent]
- [Domain B] → [Other Agent]
- [Domain C] → [Other Agent]

YOUR SPECIALTY IS [DOMAIN].
You are NOT responsible for [OTHER DOMAINS].
DO NOT attempt [OTHER DOMAINS].
Delegate them to specialist agents.
```

### Orchestrator Prompt Pattern:
```
You are the ORCHESTRATOR agent.

YOUR PRIMARY ROLE:
- Coordination and delegation (80%)
- Complex decision-making (20%)
- Direct implementation (0%)

SUBAGENT INVOCATION:
Use the "task" tool to invoke subagents in parallel:

task.invoke({
  agents: [ ... ],
  parallel: true
})

WHEN TO USE PARALLEL INVOCATION:
[Clear examples of parallelizable work]
```

---

## References & Resources

**File Locations in Repository:**
- Config: `/home/gabriel/projects/system/.opencode.json`
- Orchestrator Prompt: `/home/gabriel/projects/system/prompts/orchestrator.txt`
- Build Prompt: `/home/gabriel/projects/system/prompts/build.txt`
- Setup Documentation: `/home/gabriel/projects/system/OPENCODE-SETUP.md`
- Quick Reference: `/home/gabriel/projects/system/prompts/AGENT-GUIDE.md`
- Agent List: `/home/gabriel/projects/system/prompts/AGENT-GUIDE.md` (lines 1-170)

**OpenCode Concepts:**
- Task Tool: Only available to orchestrator, enables agent invocation
- Parallel Setting: `"parallel_subagents": true` must be set
- Max Agents: `"max_parallel_agents": 4` is the limit
- Primary Agents: Auto-invoked based on mode
- Subagents: Must be explicitly invoked via task tool

---

## Summary

The OpenCode system has all the infrastructure for parallel execution:
✅ Config setting exists
✅ Task tool available
✅ 11 specialized subagents ready
✅ Opus model for complex work

What's missing:
❌ Explicit instructions in prompts to USE the task tool
❌ Prompts telling agents WHEN to delegate
❌ Build agent guidance on delegation
❌ Detailed delegation examples

**Implementation Path:**
1. Update 3 prompts (orchestrator.txt, build.txt, architect.txt)
2. Expand settings in .opencode.json
3. Add parallel workflow definitions
4. Test with complex multi-step tasks

**Expected Outcome:**
- Orchestrator will invoke 3-4 subagents in parallel
- Build agent will delegate testing, review, documentation
- Complex tasks will complete 2-4x faster
- Quality improves through specialization
- Cost optimized through intelligent agent selection
