# Quick Agent Reference Guide

## When to Use Each Agent

### 🏗️ **Architect** (Sonnet) - Use When:

- Starting any new feature or module
- Need to design system architecture
- Evaluating multiple approaches
- Gathering requirements
- Need technical specifications

**Don't use for**: Quick fixes, documentation updates, simple edits

---

### 🔨 **Build** (Sonnet) - Use When:

- Implementing features from specs
- Writing new code modules
- Creating integrations
- Following established patterns

**Don't use for**: Design decisions, planning, testing

---

### 🧠 **Orchestrator** (Opus) - Use When:

- Task requires 5+ steps
- Need to coordinate multiple agents
- Complex multi-domain work (code + config + docs)
- Parallel execution needed
- Strategic decision-making required

**Don't use for**: Simple tasks, single-domain work

---

### 📋 **Plan** (Haiku) - Use When:

- Breaking down features into tasks
- Need clear implementation steps
- Estimating work complexity
- Creating checklists

**Don't use for**: Implementation, design decisions

---

### 👁️ **Review** (Sonnet) - Use When:

- Before committing code (auto-invokes)
- Need security analysis
- Performance concerns
- Code quality audit
- Pre-merge checks

**Don't use for**: Implementation, fixing issues

---

### ♻️ **Refactor** (Sonnet) - Use When:

- Code smells detected
- Duplication needs elimination
- Improving maintainability
- Modernizing patterns
- Simplifying complexity

**Don't use for**: New features, bug fixes

---

### 🧪 **Test** (Sonnet) - Use When:

- Writing test suites
- Implementing TDD workflow
- Need edge case coverage
- Integration testing
- Test automation

**Don't use for**: Quick fixes, documentation

---

### 🐛 **Debug** (Sonnet) - Use When:

- Complex bugs requiring investigation
- Root cause analysis needed
- Multi-layer debugging
- System-level issues

**Don't use for**: Simple bugs, typos, quick fixes

---

### 🔍 **Research** (Haiku) - Use When:

- Exploring unfamiliar codebase
- Finding patterns and examples
- Understanding dependencies
- Locating functionality
- Quick investigations

**Don't use for**: Implementation, making changes

---

### 📚 **Document** (Sonnet) - Use When:

- Writing technical documentation
- Creating user guides
- API documentation needed
- README updates
- Architecture documentation

**Don't use for**: Code comments (Build does this)

---

### ⚡ **Optimize** (Sonnet) - Use When:

- Performance bottlenecks identified
- Resource usage high
- Build times slow
- Need profiling and optimization

**Don't use for**: Premature optimization, working code

---

### ❄️ **Nix-Specialist** (Sonnet) - Use When:

- NixOS module development
- Flake configuration
- Package management
- System configuration
- Nix language questions

**Don't use for**: General programming, non-Nix tasks

---

### 🔒 **Security** (Sonnet) - Use When:

- Security audit needed
- Hardening services
- Reviewing permissions
- Secrets management
- Threat modeling

**Don't use for**: Implementation, regular reviews

---

### 🔧 **Fix** (Haiku) - Use When:

- Simple bug fix needed
- Quick iteration required
- Typo or syntax error
- Configuration tweak

**Don't use for**: Complex bugs, root cause analysis

---

## Decision Tree

```
New Work?
├─ Yes → Complex?
│  ├─ Yes → Orchestrator (coordinates everything)
│  └─ No → Architect (designs) → Build (implements)
└─ No → Problem?
   ├─ Simple bug → Fix
   ├─ Complex bug → Debug
   ├─ Performance → Optimize
   ├─ Security issue → Security
   ├─ Code quality → Refactor
   ├─ Missing tests → Test
   ├─ Need info → Research
   └─ Need docs → Document
```

## Workflow Patterns

### Pattern 1: Full Feature Development

```
Architect → Plan → Build → Test → Review → Document
```

### Pattern 2: Quick Fix

```
Fix → Test (verify)
```

### Pattern 3: Complex Bug

```
Research → Debug → Fix → Test
```

### Pattern 4: System Configuration

```
Architect → Nix-Specialist → Security → Review
```

### Pattern 5: Code Quality Improvement

```
Research → Refactor → Optimize → Test → Review
```

### Pattern 6: Parallel Implementation

```
Orchestrator →
  ├─ Build (feature A)
  ├─ Build (feature B)
  ├─ Test (both features)
  └─ Review (final check)
```

## Speed Comparison

| Speed Tier    | Agents                      | Use Case                 |
| ------------- | --------------------------- | ------------------------ |
| **Fast** ⚡   | Haiku (Plan, Research, Fix) | Quick tasks, exploration |
| **Medium** 🏃 | Sonnet (most agents)        | Main work                |
| **Slow** 🧠   | Opus (Orchestrator)         | Complex coordination     |

## Cost Optimization

### Minimize costs:

1. Use **Fix** (Haiku) for simple bugs
2. Use **Research** (Haiku) for exploration
3. Use **Plan** (Haiku) for task breakdown
4. Reserve **Orchestrator** (Opus) for truly complex tasks

### When Opus is worth it:

- Coordinating 3+ agents
- Complex architectural decisions
- Critical system changes
- Large-scale refactoring

## Common Mistakes

❌ **Using Orchestrator for simple tasks**
✅ Use specialized agents directly

❌ **Skipping Architect for new features**
✅ Always design before building

❌ **Using Build for planning**
✅ Use Architect or Plan first

❌ **Using Debug for simple typos**
✅ Use Fix for quick corrections

❌ **Manual reviews**
✅ Trust auto-review or use Review agent

## Pro Tips

💡 **Chain agents manually** for custom workflows

```bash
# Example: Custom security-focused refactor
Research → Refactor → Security → Review
```

💡 **Parallel execution** for independent tasks

```bash
# Orchestrator launches simultaneously:
Document (API) || Document (User Guide) || Document (Architecture)
```

💡 **Iterative refinement**

```bash
# For complex features:
Architect (v1) → Review feedback → Architect (v2) → Build
```

💡 **NixOS workflows** always include Nix-Specialist

```bash
Architect → Nix-Specialist → Security → Review
```

💡 **TDD workflow** with Test agent

```bash
Test (write tests) → Build (implement) → Test (verify)
```

---

**Remember**: Let agents do what they're specialized for. Don't force a hammer to be a screwdriver.
