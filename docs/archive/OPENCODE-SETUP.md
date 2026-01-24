# OpenCode Supercharged Setup

This NixOS system has a powerful OpenCode configuration inspired by the [superpowers framework](https://github.com/obra/superpowers) for maximum agent autonomy and productivity.

## Overview

The setup includes **3 primary agents** and **11 specialized subagents** that work together to handle everything from system design to security hardening.

## Primary Agents

### 🏗️ Architect (Sonnet)

**Auto-invokes before implementation**

- Leads requirements gathering through Socratic dialogue
- Designs system architecture
- Creates technical specifications
- Validates designs before implementation

### 🔨 Build (Sonnet)

**Main implementation workhorse**

- Writes production-quality code
- Follows existing patterns
- Implements features incrementally
- Ensures comprehensive error handling

### 🧠 Orchestrator (Opus - Most Powerful)

**Coordinates complex workflows**

- Manages multi-step tasks
- Launches parallel subagents
- Optimizes execution strategy
- Synthesizes results from multiple agents

## Specialized Subagents

### 📋 Plan (Haiku - Fast)

Breaks down complex tasks into actionable steps with clear priorities and dependencies.

### 👁️ Review (Sonnet)

Comprehensive code review focusing on security, performance, maintainability, and best practices.

### ♻️ Refactor (Sonnet)

Improves code structure, eliminates duplication, modernizes patterns while preserving functionality.

### 🧪 Test (Sonnet)

Creates comprehensive test suites, enforces TDD, validates edge cases.

### 🐛 Debug (Sonnet)

Systematic problem-solving, root cause analysis, targeted fixes.

### 🔍 Research (Haiku - Fast)

Deep codebase exploration, pattern discovery, dependency analysis.

### 📚 Document (Sonnet)

Technical writing, API docs, architecture guides, configuration references.

### ⚡ Optimize (Sonnet)

Performance analysis, bottleneck identification, resource optimization.

### ❄️ Nix-Specialist (Sonnet)

NixOS expert for modules, flakes, system configuration, and Nix language.

### 🔒 Security (Sonnet)

Security analysis, vulnerability detection, hardening recommendations, threat modeling.

### 🔧 Fix (Haiku - Fast)

Rapid bug fixes with minimal changes, quick iterations, immediate verification.

## Predefined Workflows

### Feature Development

```
Architect → Plan → Build → Test → Review → Document
```

### NixOS Configuration

```
Architect → Nix-Specialist → Security → Review
```

### Debugging

```
Research → Debug → Fix → Test
```

### Refactoring

```
Research → Refactor → Optimize → Test → Review
```

## How It Works

### 1. **Automatic Agent Selection**

The system automatically invokes the right agent based on the task:

- Starting a new feature? → **Architect** designs first
- Complex multi-step task? → **Orchestrator** coordinates
- Quick bug fix? → **Fix** handles it rapidly
- Security review? → **Security** analyzes thoroughly

### 2. **Parallel Execution**

The orchestrator can launch up to **4 subagents in parallel** for maximum speed:

```json
"parallel_subagents": true,
"max_parallel_agents": 4
```

### 3. **Automatic Reviews**

Before any commit, the **Review** agent automatically checks:

```json
"auto_review_before_commit": true
```

### 4. **Persistent Task Memory with Beads**

All agents share a **git-backed task graph** to eliminate context loss:

- **Cross-session memory** - Work persists between agent invocations
- **Dependency tracking** - Tasks block/unblock automatically
- **Multi-agent coordination** - Orchestrator creates epics, delegates to subagents
- **Audit trail** - Full history of decisions and implementations

```bash
# Orchestrator creates epic
bd create "Feature: Add monitoring" -p 0 --epic

# Delegates to subagents
bd create "Design monitoring architecture" --parent <epic-id>
bd create "Implement NixOS module" --parent <epic-id>

# Agents query ready work
bd ready  # Shows unblocked tasks

# Complete with context
bd done <task-id> "Completed: Added Prometheus module with systemd hardening"
```

**Beads Storage:**

- `.beads/issues/` - Task database (committed to git)
- `.beads/cache/` - SQLite cache (local only, gitignored)

**Documentation:**

- [Beads Agent Guide](docs/BEADS_AGENT_GUIDE.md) - Complete reference
- [Beads Examples](docs/BEADS_EXAMPLES.md) - Real workflows
- [Beads Hierarchy](docs/BEADS_HIERARCHY.md) - Task structure
- [Beads Workflows](docs/BEADS_WORKFLOWS.md) - Agent procedures
- [Beads Multi-Repo](docs/BEADS_MULTI_REPO.md) - Using Beads across projects

## Agent Capabilities Matrix

| Agent          | Write | Edit | Bash | Research | TDD Focus      | Speed       |
| -------------- | ----- | ---- | ---- | -------- | -------------- | ----------- |
| Architect      | ✓     | ✗    | ✓    | ✓        | Design         | Medium      |
| Build          | ✓     | ✓    | ✓    | ✓        | Implementation | Medium      |
| Orchestrator   | ✓     | ✓    | ✓    | ✓        | Coordination   | Slow (Opus) |
| Plan           | ✓     | ✗    | ✗    | ✓        | Planning       | **Fast**    |
| Review         | ✗     | ✗    | ✓    | ✓        | Quality        | Medium      |
| Refactor       | ✗     | ✓    | ✓    | ✓        | Improvement    | Medium      |
| Test           | ✓     | ✓    | ✓    | ✓        | **TDD**        | Medium      |
| Debug          | ✗     | ✓    | ✓    | ✓        | Root Cause     | Medium      |
| Research       | ✗     | ✗    | ✓    | ✓        | Exploration    | **Fast**    |
| Document       | ✓     | ✓    | ✗    | ✓        | Writing        | Medium      |
| Optimize       | ✗     | ✓    | ✓    | ✓        | Performance    | Medium      |
| Nix-Specialist | ✓     | ✓    | ✓    | ✓        | NixOS          | Medium      |
| Security       | ✗     | ✗    | ✓    | ✓        | Hardening      | Medium      |
| Fix            | ✗     | ✓    | ✓    | ✓        | Speed          | **Fast**    |

## Model Distribution

- **Claude Opus (slowest, smartest)**: 1 agent (Orchestrator)
- **Claude Sonnet (balanced)**: 9 agents (most work)
- **Claude Haiku (fastest, efficient)**: 3 agents (Plan, Research, Fix)

This distribution optimizes for:

- Cost efficiency (Haiku for simple tasks)
- Quality (Sonnet for main work)
- Intelligence (Opus for complex coordination)

## Usage Examples

### Starting a New Feature

```bash
# User: "Add a new NixOS module for monitoring"
# 1. Architect asks clarifying questions
# 2. Architect designs the module structure
# 3. Plan breaks it into tasks
# 4. Build implements incrementally
# 5. Test creates validation tests
# 6. Review checks quality
# 7. Document writes module docs
```

### Complex System Configuration

```bash
# User: "Set up a secure web server with SSL"
# 1. Orchestrator analyzes scope
# 2. Architect designs the setup
# 3. Nix-Specialist implements config
# 4. Security hardens the setup
# 5. Review validates everything
```

### Debugging Production Issue

```bash
# User: "Service won't start after reboot"
# 1. Research investigates logs
# 2. Debug identifies root cause
# 3. Fix applies minimal patch
# 4. Test verifies the fix
```

### Large-Scale Refactoring

```bash
# User: "Refactor the module structure"
# 1. Orchestrator creates strategy
# 2. Research maps current structure
# 3. Refactor transforms code (in parallel)
# 4. Optimize improves performance
# 5. Test validates all functionality
# 6. Review ensures quality
```

## Key Features

### 🚀 Subagent-Driven Development

Instead of one agent doing everything, specialized agents handle their domain:

- Faster execution through parallelization
- Better quality through specialization
- Clearer responsibilities and workflows

### 🎯 Test-Driven Development

The **Test** agent enforces RED-GREEN-REFACTOR:

1. Write failing test
2. Watch it fail
3. Write minimal code
4. Watch it pass
5. Commit

### 🔐 Security-First

The **Security** agent analyzes:

- Systemd hardening (PrivateTmp, NoNewPrivileges, etc.)
- Service isolation and sandboxing
- Secrets management
- Attack surface reduction

### ❄️ NixOS Expertise

The **Nix-Specialist** handles:

- Module system (options, config, imports)
- Flakes and dependency management
- Reproducible builds
- System hardening

## Files Structure

```
/home/gabriel/projects/system/
├── .opencode.json          # Main configuration
├── .beads/                 # Beads task memory
│   ├── issues/             # Task database (committed to git)
│   └── cache/              # SQLite cache (gitignored)
├── prompts/                # Agent instructions
│   ├── architect.txt
│   ├── build.txt
│   ├── orchestrator.txt
│   ├── plan.txt
│   ├── review.txt
│   ├── refactor.txt
│   ├── test.txt
│   ├── debug.txt
│   ├── research.txt
│   ├── document.txt
│   ├── optimize.txt
│   ├── nix-specialist.txt
│   ├── security.txt
│   └── fix.txt
├── docs/                   # Documentation
│   ├── BEADS_AGENT_GUIDE.md
│   ├── BEADS_EXAMPLES.md
│   ├── BEADS_HIERARCHY.md
│   └── BEADS_WORKFLOWS.md
├── scripts/
│   └── init-beads.sh       # Beads initialization
├── modules/
│   └── home/
│       └── beads.nix       # Beads NixOS module
└── OPENCODE-SETUP.md       # This file
```

## Philosophy

### From Superpowers Framework

1. **Design before implementation** - Architect leads, Build follows
2. **Systematic over ad-hoc** - Process-driven workflows
3. **Complexity reduction** - Simplicity as primary goal
4. **Evidence over claims** - Test and verify everything

### NixOS-Specific

1. **Declarative > Imperative** - System as code
2. **Reproducible** - Same config, same result
3. **Modular** - Compose functionality cleanly
4. **Secure by default** - Hardening built-in

## Tips

1. **Trust the Architect** - Let it design before jumping to code
2. **Use Orchestrator for complex tasks** - It's your smartest coordinator
3. **Leverage parallel execution** - Multiple agents = faster results
4. **Let specialists do their job** - Nix-Specialist for NixOS, Security for hardening
5. **Review is automatic** - But you can invoke it manually anytime

## Troubleshooting

### Agent not auto-invoking?

Check `.opencode.json` settings:

```json
"auto_invoke_architect": true
```

### Need to customize an agent?

Edit the corresponding file in `prompts/`

### Want to add a new agent?

1. Create prompt file in `prompts/`
2. Add agent definition to `.opencode.json`
3. Define its mode, model, and tools

## References

- [Superpowers Framework](https://github.com/obra/superpowers)
- [OpenCode Documentation](https://opencode.ai/docs)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Beads GitHub](https://github.com/steveyegge/beads) - Git-backed issue tracker for AI agents

---

**Built for maximum autonomy, quality, and speed with persistent memory.**
