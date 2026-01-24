# OpenCode Configuration

This NixOS system includes a comprehensive OpenCode agent setup managed through Home Manager.

## Location

The OpenCode configuration is managed at:

- **Module**: `modules/home/opencode.nix`
- **Installed to**: `~/.config/opencode/opencode.json`
- **Prompts**: `~/.config/opencode/prompts/*.md`

## What's Included

### 14 Specialized Agents

**Primary Agents (3):**

- **Architect** (Sonnet 4.5) - Design and planning
- **Build** (Sonnet 4.5) - Implementation
- **Orchestrator** (Opus 4.5) - Workflow coordination

**Subagents (11):**

- **Plan** (Haiku 4.5) - Task breakdown
- **Review** (Sonnet 4.5) - Code review
- **Refactor** (Sonnet 4.5) - Code improvement
- **Test** (Sonnet 4.5) - TDD and testing
- **Debug** (Sonnet 4.5) - Problem diagnosis
- **Research** (Haiku 4.5) - Codebase exploration
- **Document** (Sonnet 4.5) - Technical writing
- **Optimize** (Sonnet 4.5) - Performance tuning
- **Nix-Specialist** (Sonnet 4.5) - NixOS expertise
- **Security** (Sonnet 4.5) - Security hardening
- **Fix** (Haiku 4.5) - Quick bug fixes

### 4 Predefined Workflows

1. **Feature Development**: Architect → Plan → Build → Test → Review → Document
2. **NixOS Configuration**: Architect → Nix-Specialist → Security → Review
3. **Debugging**: Research → Debug → Fix → Test
4. **Refactoring**: Research → Refactor → Optimize → Test → Review

## Model Distribution

- **Claude Opus 4.5** (1 agent): Orchestrator - for complex coordination
- **Claude Sonnet 4.5** (10 agents): Most specialized work
- **Claude Haiku 4.5** (3 agents): Fast operations (Plan, Research, Fix)

## Usage

After rebuilding your system, OpenCode will automatically use this configuration:

```bash
# Start OpenCode with your configured agents
opencode

# Run a specific agent
opencode run --agent nix-specialist "help me configure a service"

# Use orchestrator for complex tasks
opencode run --agent orchestrator "refactor the home modules"
```

## Customization

To modify the configuration, edit `modules/home/opencode.nix` and rebuild:

```bash
sudo nixos-rebuild switch --flake .#laptop
```

Changes to agent prompts require editing the prompt files in the module.

## Agent Prompts

All agent prompts are stored as markdown files in `~/.config/opencode/prompts/`. These are sourced from the `prompts/` directory in this repository and symlinked by Home Manager.

## Features

- **Auto-invoke Architect**: Automatically starts design before implementation
- **Auto-review**: Reviews code before commits
- **Parallel Execution**: Run up to 4 agents simultaneously
- **Declarative**: Configuration managed through NixOS
- **Reproducible**: Same config on all your machines

## References

- Main documentation: `OPENCODE-SETUP.md`
- Quick reference: `prompts/AGENT-GUIDE.md`
- OpenCode docs: https://opencode.ai/docs
- Superpowers inspiration: https://github.com/obra/superpowers
