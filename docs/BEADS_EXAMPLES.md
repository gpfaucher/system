# Beads Examples: Real-World Multi-Agent Scenarios

**Version**: 1.0  
**Last Updated**: 2026-01-23  
**Purpose**: Practical examples showing complete Beads workflows with multiple coordinating agents

---

## Overview

This document provides **complete, real-world scenarios** showing how multiple agents coordinate through Beads to accomplish complex tasks. Each scenario includes:

- Full command sequences
- Agent transitions and handoffs
- Expected outputs and results
- Timeline estimates
- Key decision points

These examples complement the [main Beads guide](./BEADS_AGENT_GUIDE.md) with practical, copy-pasteable workflows.

---

## Scenario 1: Adding a New NixOS Module

**User Request**: "Create a new NixOS module for a monitoring service with automatic SSL certificate management"

**Complexity**: High (Architecture + NixOS + Security + Documentation)  
**Agents Involved**: 5 (Orchestrator, Architect, Nix-Specialist, Security, Document)  
**Estimated Duration**: 2-3 hours  
**Pattern**: Sequential with parallel review

### Phase 1: Orchestrator Creates Epic (5 minutes)

```bash
# Orchestrator receives request and creates epic
bd create "Epic: NixOS module for monitoring service" \
  --priority P1 \
  --tag nixos,feature,infrastructure

# Output:
# Created task bd-a1b2c3: Epic: NixOS module for monitoring service
# Status: backlog
# ID: 100

# Break into subtasks with dependencies
bd create "Design monitoring module architecture" \
  --epic 100 \
  --assign architect \
  --priority P1 \
  --tag architecture,nixos

# Output: Created task bd-a1b2c3.1: Design monitoring module architecture
# ID: 101

bd create "Research NixOS SSL certificate options" \
  --epic 100 \
  --assign nix-specialist \
  --priority P1 \
  --tag research,nixos,ssl

# Output: Created task bd-a1b2c3.2: Research NixOS SSL certificate options
# ID: 102

# Set dependencies: Design and Research must complete before implementation
bd dep add 101 --blocks 103
bd dep add 102 --blocks 103

bd create "Implement monitoring service NixOS module" \
  --epic 100 \
  --assign nix-specialist \
  --priority P1 \
  --tag implementation,nixos

# Output: Created task bd-a1b2c3.3: Implement monitoring service NixOS module
# ID: 103
# Status: backlog (blocked by 101, 102)

# Parallel review tasks
bd create "Security audit module configuration" \
  --epic 100 \
  --assign security \
  --priority P1 \
  --tag security,review

# Output: Created task bd-a1b2c3.4: Security audit module configuration
# ID: 104

bd dep add 103 --blocks 104  # Can't audit until implemented

bd create "Document monitoring module usage" \
  --epic 100 \
  --assign document \
  --priority P1 \
  --tag documentation

# Output: Created task bd-a1b2c3.5: Document monitoring module usage
# ID: 105

bd dep add 103 104 --blocks 105  # Docs wait for implementation + security

# Mark first two tasks as ready (no blockers)
bd ready 101 102

# View epic status
bd show 100

# Output:
# Task bd-a1b2c3: Epic: NixOS module for monitoring service
# Status: backlog
# Priority: P1
# Subtasks: 5 total (2 ready, 3 blocked)
#   ✓ 101: Design monitoring module architecture [ready] → architect
#   ✓ 102: Research NixOS SSL certificate options [ready] → nix-specialist
#   ⊗ 103: Implement monitoring service NixOS module [blocked by 101, 102]
#   ⊗ 104: Security audit module configuration [blocked by 103]
#   ⊗ 105: Document monitoring module usage [blocked by 103, 104]
```

**Orchestrator hands off**: Tasks 101 and 102 are now ready for Architect and Nix-Specialist to work in parallel.

---

### Phase 2: Parallel Design + Research (30 minutes)

#### Architect (Agent A)

```bash
# Architect checks for work
bd ready --assign architect

# Output:
# 101: Design monitoring module architecture [P1] [epic: 100]

# Start work
bd update 101 --status in-progress

# Output:
# Updated task 101: status → in-progress

# Architect designs the module structure:
# - Creates docs/architecture/monitoring-module.md
# - Defines module options structure
# - Plans service systemd integration
# - Designs SSL certificate integration points

# Complete with detailed notes
bd done 101 --comment "Architecture complete. See docs/architecture/monitoring-module.md. 
Key decisions:
- Use systemd-based service with dynamic user
- Integrate with security.acme for SSL certs
- Config validation using NixOS type system
- Separate module for monitoring backend vs frontend"

# Output:
# Task 101 completed
# Tasks unblocked: 103 (if all blockers done)
```

#### Nix-Specialist (Agent B) - Working in Parallel

```bash
# Nix-Specialist checks for work
bd ready --assign nix-specialist

# Output:
# 102: Research NixOS SSL certificate options [P1] [epic: 100]

# Start work
bd update 102 --status in-progress

# Nix-Specialist researches:
# - Reads NixOS security.acme module docs
# - Tests ACME integration patterns
# - Reviews existing modules with SSL

# Complete with findings
bd done 102 --comment "Research complete. Findings:
- Use security.acme.certs.<name> for automatic renewal
- Must define extraDomainNames for multi-domain certs
- Recommend letsencrypt for production
- Need nginx/apache reverse proxy for HTTP challenge
See research notes in .beads/issues/102-research.md"

# Output:
# Task 102 completed
# Tasks unblocked: 103 (now both blockers done)
```

**Result**: 30 minutes elapsed, 2 tasks complete in parallel. Task 103 now automatically becomes `ready`.

---

### Phase 3: Implementation (60 minutes)

```bash
# Nix-Specialist checks for newly unblocked work
bd ready --assign nix-specialist

# Output:
# 103: Implement monitoring service NixOS module [P1] [epic: 100]

# Start implementation
bd update 103 --status in-progress

# Nix-Specialist implements:
# 1. Creates modules/services/monitoring/default.nix
# 2. Defines options (enable, port, ssl.enable, ssl.domain, etc.)
# 3. Implements systemd service configuration
# 4. Integrates with security.acme
# 5. Adds package dependencies
# 6. Writes module tests

# During implementation, discovers need for package customization
bd create "Create monitoring service package derivation" \
  --priority P2 \
  --tag nixos,package \
  --assign nix-specialist

# Output: Created task 106: Create monitoring service package derivation

# Complete main task
bd done 103 --comment "Module implemented in modules/services/monitoring/default.nix.
Features:
- Full NixOS module with type-checked options
- Automatic SSL via security.acme integration
- Systemd service with dynamic user
- Configuration validation
- Built-in health checks
Tested locally with: nixos-rebuild test
Ready for security review.
Created follow-up task #106 for package customization."

# Output:
# Task 103 completed
# Tasks unblocked: 104 (security audit now ready)
```

**Result**: 60 minutes elapsed, 1 task complete. Security audit unblocked.

---

### Phase 4: Parallel Security Audit (30 minutes)

```bash
# Security agent checks for work
bd ready --assign security

# Output:
# 104: Security audit module configuration [P1] [epic: 100]

# Start audit
bd update 104 --status in-progress

# Security agent reviews:
# - Checks SSL certificate permissions
# - Validates systemd service hardening
# - Reviews network exposure
# - Tests configuration validation
# - Checks for secrets management

# Security agent finds minor issue
bd create "Harden monitoring service systemd config" \
  --priority P1 \
  --tag security,nixos \
  --assign nix-specialist

# Output: Created task 107: Harden monitoring service systemd config

bd dep add 107 --blocks 105  # Docs should reflect hardened version

# Complete audit with recommendations
bd done 104 --comment "Security audit complete.
Findings:
✓ SSL certificate integration secure
✓ Dynamic user properly configured
⚠ Recommend additional systemd hardening (created task #107)
✓ Configuration validation prevents injection attacks
✓ Network isolation appropriate

Recommendations:
- Add ProtectSystem=strict, PrivateTmp=true (task #107)
- Consider adding rate limiting for API endpoints
- Document security best practices in module docs

Overall: APPROVED with minor hardening suggestions in #107"

# Output:
# Task 104 completed
# Tasks unblocked: 105 (if #107 is quick-fixed)
```

**Quick Fix** (Nix-Specialist handles immediately):

```bash
bd update 107 --status in-progress
# Makes systemd hardening changes
bd done 107 --comment "Added systemd hardening:
- ProtectSystem=strict
- PrivateTmp=true
- NoNewPrivileges=true
- ProtectKernelTunables=true
Updated module and tested successfully."

# Output: Task 107 completed
# Tasks unblocked: 105
```

**Result**: 30 minutes elapsed, 2 tasks complete (audit + quick fix).

---

### Phase 5: Documentation (30 minutes)

```bash
# Document agent checks for work
bd ready --assign document

# Output:
# 105: Document monitoring module usage [P1] [epic: 100]

# Start documentation
bd update 105 --status in-progress

# Document agent creates:
# 1. docs/modules/monitoring.md (user guide)
# 2. Adds module to docs/index.md
# 3. Creates example configurations
# 4. Documents SSL setup steps
# 5. Adds troubleshooting section

# Complete with thorough documentation
bd done 105 --comment "Documentation complete:
- User guide: docs/modules/monitoring.md
- Example configs for common scenarios
- SSL setup walkthrough
- Troubleshooting section
- Added to main documentation index
- Includes security best practices from audit #104
All examples tested and working."

# Output:
# Task 105 completed
```

**Result**: 30 minutes elapsed, documentation complete.

---

### Phase 6: Orchestrator Verification & Closure (10 minutes)

```bash
# Orchestrator checks epic status
bd show 100

# Output:
# Task bd-a1b2c3: Epic: NixOS module for monitoring service
# Status: backlog
# Priority: P1
# Subtasks: 7 total (5 done, 2 new follow-ups)
#   ✓ 101: Design monitoring module architecture [done]
#   ✓ 102: Research NixOS SSL certificate options [done]
#   ✓ 103: Implement monitoring service NixOS module [done]
#   ✓ 104: Security audit module configuration [done]
#   ✓ 105: Document monitoring module usage [done]
# Follow-ups created:
#   □ 106: Create monitoring service package derivation [backlog] [P2]
#   ✓ 107: Harden monitoring service systemd config [done]

# Orchestrator reviews completed work
bd show 101 --comments
bd show 103 --comments
bd show 104 --comments
bd show 105 --comments

# Verification:
# ✓ Architecture documented and sound
# ✓ Implementation complete and tested
# ✓ Security approved with hardening applied
# ✓ Documentation comprehensive

# Close completed epic and tasks
bd close 101 102 103 104 105 107
bd update 100 --status done
bd close 100

# Output:
# Closed 7 tasks
# Epic 100 complete
```

**Final Summary**:
- **Total Duration**: ~2.5 hours
- **Tasks Created**: 7 (5 main + 2 follow-ups)
- **Tasks Completed**: 6 (1 follow-up deferred to P2)
- **Agents Coordinated**: 5
- **Parallel Work**: 2 phases (Design+Research, Audit+Fix)
- **Result**: Production-ready NixOS module with security approval and documentation

---

## Scenario 2: Debugging a Production Issue

**User Report**: "API endpoint /api/users returning 500 errors intermittently"

**Complexity**: Medium (Investigation + Fix + Testing)  
**Agents Involved**: 4 (Debug, Fix, Test, Review)  
**Estimated Duration**: 45-60 minutes  
**Pattern**: Sequential debugging pipeline

### Phase 1: Initial Triage (5 minutes)

```bash
# User or orchestrator creates urgent bug task
bd create "CRITICAL: /api/users endpoint returning 500 errors" \
  --priority P0 \
  --tag bug,urgent,api \
  --assign debug

# Output: Created task 200: CRITICAL: /api/users endpoint returning 500 errors

bd ready 200

# Output: Task 200 marked as ready

# View task
bd show 200

# Output:
# Task 200: CRITICAL: /api/users endpoint returning 500 errors
# Status: ready
# Priority: P0
# Assignee: debug
# Tags: bug, urgent, api
```

---

### Phase 2: Debug Investigation (15 minutes)

```bash
# Debug agent starts investigation
bd update 200 --status in-progress

# Debug agent investigates:
# - Checks application logs
# - Reviews error traces
# - Tests endpoint locally
# - Checks database connections
# - Reviews recent code changes

# Finds root cause
bd update 200 --description "Root cause identified:
Database query timeout when users table exceeds 10k rows.
Missing index on users.email column causing full table scan.
Query: SELECT * FROM users WHERE email = ? ORDER BY created_at DESC
Timeout after 30s when table has 50k+ rows.

Error stack trace in logs/api-2026-01-23.log line 1247"

# Create fix task immediately
bd create "Add database index on users.email column" \
  --priority P0 \
  --tag bug,database,fix \
  --assign fix

# Output: Created task 201: Add database index on users.email column

bd dep add 200 --blocks 201  # Investigation findings inform fix

# Complete investigation
bd done 200 --comment "Root cause: Missing database index on users.email.
Full analysis in task description.
Created fix task #201.
Recommended: Add query timeout monitoring to prevent future issues."

# Output:
# Task 200 completed
# Task 201 unblocked and ready
```

**Result**: 15 minutes elapsed, root cause identified, fix task created.

---

### Phase 3: Implement Fix (15 minutes)

```bash
# Fix agent picks up ready task
bd ready --assign fix --priority P0

# Output:
# 201: Add database index on users.email column [P0]

bd update 201 --status in-progress

# Fix agent implements:
# 1. Creates database migration: migrations/20260123_add_users_email_index.sql
# 2. Tests migration locally
# 3. Verifies query performance improvement
# 4. Prepares rollback plan

# Create testing task
bd create "Verify /api/users endpoint performance after fix" \
  --priority P0 \
  --tag testing,verification \
  --assign test

# Output: Created task 202: Verify /api/users endpoint performance after fix

bd dep add 201 --blocks 202  # Can't test until fix deployed

# Complete fix
bd done 201 --comment "Database migration created and tested locally.
Migration: migrations/20260123_add_users_email_index.sql
Results:
- Query time: 28s → 0.3s (93x faster)
- Index size: 15MB
- No downtime required
- Tested with 100k row test dataset
Ready for production deployment and verification.
Created test task #202."

# Output:
# Task 201 completed
# Task 202 unblocked
```

**Result**: 15 minutes elapsed, fix implemented and tested locally.

---

### Phase 4: Production Verification (15 minutes)

```bash
# Test agent verifies fix in production
bd update 202 --status in-progress

# Test agent:
# 1. Monitors deployment of migration
# 2. Tests /api/users endpoint with various queries
# 3. Monitors error logs
# 4. Checks database performance metrics
# 5. Tests with high concurrency

# Discovers edge case
bd create "Investigate slow query on users.email LIKE pattern" \
  --priority P2 \
  --tag performance,follow-up \
  --assign optimize

# Output: Created task 203: Investigate slow query on users.email LIKE pattern

# Verification complete
bd done 202 --comment "Production verification complete:
✓ /api/users endpoint responding in <500ms (was 30s+)
✓ No 500 errors in last 1000 requests
✓ Database index performing well
✓ Error logs clear
✓ Load tested with 100 concurrent requests - stable

Minor follow-up: LIKE queries still slow (created task #203 for future optimization)
Issue RESOLVED."

# Output: Task 202 completed
```

**Result**: 15 minutes elapsed, production fix verified.

---

### Phase 5: Code Review & Closure (10 minutes)

```bash
# Review agent performs post-incident review
bd create "Code review: database migration #201" \
  --priority P1 \
  --tag review,post-incident \
  --assign review

# Output: Created task 204: Code review: database migration #201

bd update 204 --status in-progress

# Review agent:
# - Reviews migration code
# - Checks index strategy
# - Validates rollback plan
# - Reviews monitoring gaps

bd done 204 --comment "Post-incident code review complete:
✓ Migration code correct and safe
✓ Index strategy appropriate
✓ Rollback plan documented
⚠ Recommendation: Add automated query performance monitoring
⚠ Recommendation: Document indexing strategy in database docs

APPROVED for long-term production use.
Consider query monitoring task for future work."

# Close incident tasks
bd close 200 201 202 204

# Output: Closed 4 tasks
```

**Final Summary**:
- **Total Duration**: ~60 minutes (from report to resolution)
- **Tasks Created**: 5 (3 critical path + 2 follow-ups)
- **Tasks Completed**: 4 (1 follow-up deferred to P2)
- **Agents Coordinated**: 4 (Debug → Fix → Test → Review)
- **Result**: Production issue resolved, verified, and reviewed
- **MTTR**: 60 minutes (industry average: 4+ hours)

---

## Scenario 3: Large Refactoring with Parallel Execution

**User Request**: "Refactor authentication system to support multiple auth providers (OAuth, SAML, LDAP)"

**Complexity**: Very High (Architecture + 4 parallel implementations)  
**Agents Involved**: 7 (Orchestrator, Architect, 3× Build, Test, Document)  
**Estimated Duration**: 4-6 hours  
**Pattern**: Design → Fan-out parallel work → Fan-in integration

### Phase 1: Orchestrator Creates Strategy (10 minutes)

```bash
# Orchestrator creates epic
bd create "Epic: Multi-provider authentication refactoring" \
  --priority P1 \
  --tag epic,refactor,authentication

# Output: Created task bd-x7y8z9: Epic: Multi-provider authentication refactoring
# ID: 300

# Architect designs first
bd create "Design multi-provider auth architecture" \
  --epic 300 \
  --assign architect \
  --priority P1 \
  --tag architecture,design

# Output: Created task 301: Design multi-provider auth architecture

bd ready 301
```

---

### Phase 2: Architect Designs System (45 minutes)

```bash
# Architect designs comprehensive architecture
bd update 301 --status in-progress

# Architect creates:
# - Abstract AuthProvider interface
# - Provider registry pattern
# - Token standardization
# - Session management refactor
# - Migration strategy

bd done 301 --comment "Architecture complete: docs/architecture/auth-providers.md

Design decisions:
1. Abstract AuthProvider trait with authenticate() method
2. Provider registry for dynamic provider loading
3. Unified token format (JWT with provider metadata)
4. Backward compatible with existing auth
5. Migration path: parallel authentication during transition

Implementation breakdown:
- Core abstraction: AuthProvider trait + registry (BUILD-A)
- OAuth provider: Google, GitHub (BUILD-B)
- SAML provider: Enterprise SSO (BUILD-C)
- LDAP provider: Active Directory (BUILD-D)
- Integration tests: All providers (TEST)
- Documentation: Setup guides (DOCUMENT)

Ready for parallel implementation."

# Output: Task 301 completed
```

---

### Phase 3: Orchestrator Delegates Parallel Work (15 minutes)

```bash
# Orchestrator creates parallel implementation tasks
bd create "Implement AuthProvider core abstraction" \
  --epic 300 \
  --assign build \
  --priority P1 \
  --tag implementation,core

# Output: Created task 302: Implement AuthProvider core abstraction

bd dep add 301 --blocks 302

bd create "Implement OAuth provider (Google, GitHub)" \
  --epic 300 \
  --assign build \
  --priority P1 \
  --tag implementation,oauth

# Output: Created task 303: Implement OAuth provider (Google, GitHub)

bd create "Implement SAML provider (Enterprise SSO)" \
  --epic 300 \
  --assign build \
  --priority P1 \
  --tag implementation,saml

# Output: Created task 304: Implement SAML provider (Enterprise SSO)

bd create "Implement LDAP provider (Active Directory)" \
  --epic 300 \
  --assign build \
  --priority P1 \
  --tag implementation,ldap

# Output: Created task 305: Implement LDAP provider (Active Directory)

# Core must complete before specific providers
bd dep add 302 --blocks 303 304 305

# Integration testing after all implementations
bd create "Integration tests for all auth providers" \
  --epic 300 \
  --assign test \
  --priority P1 \
  --tag testing,integration

# Output: Created task 306: Integration tests for all auth providers

bd dep add 303 304 305 --blocks 306  # All providers before integration

# Documentation
bd create "Document multi-provider auth setup" \
  --epic 300 \
  --assign document \
  --priority P1 \
  --tag documentation

# Output: Created task 307: Document multi-provider auth setup

bd dep add 306 --blocks 307  # Docs after testing confirms it works

# Mark core task as ready
bd ready 302

# View dependency graph
bd show 300

# Output:
# Epic 300: Multi-provider authentication refactoring
# Dependency graph:
#   301 [done] → 302 [ready]
#   302 [ready] → 303, 304, 305 [blocked]
#   303, 304, 305 [blocked] → 306 [blocked]
#   306 [blocked] → 307 [blocked]
```

---

### Phase 4: Core Implementation (60 minutes)

```bash
# Build agent implements core abstraction
bd update 302 --status in-progress

# Build agent creates:
# - lib/auth/provider.rs (AuthProvider trait)
# - lib/auth/registry.rs (Provider registry)
# - lib/auth/token.rs (Unified token format)
# - lib/auth/session.rs (Session management)

bd done 302 --comment "Core auth abstraction complete:
- AuthProvider trait defined with authenticate(), validate(), refresh()
- ProviderRegistry for runtime provider registration
- Unified AuthToken with provider metadata
- Backward compatible with existing sessions

Files:
- lib/auth/provider.rs
- lib/auth/registry.rs
- lib/auth/token.rs
- lib/auth/session.rs

All core tests passing (92% coverage).
Ready for provider implementations."

# Output:
# Task 302 completed
# Tasks unblocked: 303, 304, 305 (all ready now)
```

---

### Phase 5: Parallel Provider Implementation (90 minutes)

**Note**: In practice, these could be different build agents or the same agent working sequentially. For this example, we'll show them as if parallel.

#### Build Agent A: OAuth Provider (90 minutes)

```bash
bd update 303 --status in-progress

# Implements OAuth for Google and GitHub
# - lib/auth/providers/oauth/google.rs
# - lib/auth/providers/oauth/github.rs
# - OAuth flow handling
# - Token exchange
# - User profile mapping

bd done 303 --comment "OAuth provider implementation complete:
- Google OAuth 2.0 support
- GitHub OAuth support
- Automatic user profile sync
- Token refresh handling
- Comprehensive error handling

Tested with:
- Google Workspace accounts
- GitHub personal + org accounts
- Token expiration/refresh flows

All tests passing."
```

#### Build Agent B: SAML Provider (90 minutes)

```bash
bd update 304 --status in-progress

# Implements SAML 2.0
# - lib/auth/providers/saml/mod.rs
# - SAML assertion parsing
# - IdP metadata handling
# - Attribute mapping

bd done 304 --comment "SAML provider implementation complete:
- SAML 2.0 SP implementation
- IdP metadata import
- Assertion validation
- Attribute mapping (email, groups, name)
- Session management

Tested with:
- Okta
- Azure AD
- OneLogin

All tests passing."
```

#### Build Agent C: LDAP Provider (90 minutes)

```bash
bd update 305 --status in-progress

# Implements LDAP/Active Directory
# - lib/auth/providers/ldap/mod.rs
# - LDAP bind authentication
# - Group membership queries
# - Attribute mapping

bd done 305 --comment "LDAP provider implementation complete:
- LDAP bind authentication
- Active Directory compatibility
- Group membership resolution
- Nested group support
- Connection pooling

Tested with:
- OpenLDAP
- Active Directory
- FreeIPA

All tests passing."
```

**Result**: 90 minutes elapsed, 3 provider implementations complete in parallel.

---

### Phase 6: Integration Testing (45 minutes)

```bash
# Test agent runs comprehensive integration tests
bd update 306 --status in-progress

# Test agent creates:
# - tests/integration/auth_providers_test.rs
# - Tests all providers with real credentials (test accounts)
# - Tests provider switching
# - Tests simultaneous multi-provider usage
# - Tests migration scenarios

bd done 306 --comment "Integration testing complete:
✓ All 4 providers (OAuth, SAML, LDAP, legacy) working
✓ Provider switching seamless
✓ Multi-provider sessions supported
✓ Migration from legacy auth tested
✓ Security audit passed (no credential leakage)
✓ Performance acceptable (<100ms provider overhead)

Test coverage: 94%
All integration tests passing (127 tests)

Ready for documentation and deployment."

# Output: Task 306 completed, task 307 unblocked
```

---

### Phase 7: Documentation (45 minutes)

```bash
# Document agent creates comprehensive docs
bd update 307 --status in-progress

# Document agent creates:
# - docs/auth/multi-provider-setup.md
# - docs/auth/oauth-setup.md
# - docs/auth/saml-setup.md
# - docs/auth/ldap-setup.md
# - Migration guide
# - Configuration examples

bd done 307 --comment "Documentation complete:
- Setup guides for all 4 providers
- Configuration examples for each
- Migration guide from legacy auth
- Troubleshooting section
- Security best practices
- Provider comparison matrix

All examples tested and verified.
Added to main docs index."

# Output: Task 307 completed
```

---

### Phase 8: Orchestrator Review & Closure (15 minutes)

```bash
# Orchestrator reviews epic
bd show 300

# Output:
# Epic 300: Multi-provider authentication refactoring
# Status: backlog
# Subtasks: 7 total (7 done)
#   ✓ 301: Design multi-provider auth architecture [done]
#   ✓ 302: Implement AuthProvider core abstraction [done]
#   ✓ 303: Implement OAuth provider [done]
#   ✓ 304: Implement SAML provider [done]
#   ✓ 305: Implement LDAP provider [done]
#   ✓ 306: Integration tests for all auth providers [done]
#   ✓ 307: Document multi-provider auth setup [done]

# Orchestrator verifies each component
bd show 301 --comments  # Architecture sound
bd show 302 --comments  # Core solid
bd show 303 304 305 --comments  # All providers working
bd show 306 --comments  # Tests comprehensive
bd show 307 --comments  # Docs complete

# Close epic and all tasks
bd close 301 302 303 304 305 306 307
bd update 300 --status done
bd close 300

# Output: Epic 300 and 7 tasks closed successfully
```

**Final Summary**:
- **Total Duration**: ~4.5 hours
- **Tasks Created**: 8 (1 epic + 7 subtasks)
- **Tasks Completed**: 8
- **Agents Coordinated**: 7
- **Parallel Phases**: 
  - Phase 2: Architecture (1 agent, 45 min)
  - Phase 4: Core (1 agent, 60 min)
  - Phase 5: Providers (3 agents parallel, 90 min)
  - Phase 6: Testing (1 agent, 45 min)
  - Phase 7: Docs (1 agent, 45 min)
- **Sequential Duration if no parallelization**: ~7.5 hours
- **Time Saved**: 3 hours (40% faster)
- **Result**: Complete authentication refactoring with 4 providers, tested and documented

---

## Key Patterns Demonstrated

### 1. Sequential Delegation
**Scenario 1**: Architect → Nix-Specialist → Security → Document  
**When to use**: Each step requires output from previous step  
**Coordination**: `bd dep add X --blocks Y`

### 2. Parallel Execution
**Scenario 1**: Architect + Nix-Specialist work simultaneously  
**Scenario 3**: 3 Build agents implement providers simultaneously  
**When to use**: Tasks are independent and can run concurrently  
**Coordination**: Mark multiple tasks as `ready` simultaneously

### 3. Fan-out / Fan-in
**Scenario 3**: Core → (Provider A, Provider B, Provider C) → Integration  
**When to use**: Multiple parallel implementations that must integrate  
**Coordination**: Core blocks all, all block integration

### 4. Rapid Debugging Pipeline
**Scenario 2**: Debug → Fix → Test → Review  
**When to use**: Production incidents requiring fast iteration  
**Coordination**: Each step immediately creates next step's task

---

## Timeline Estimation Guidelines

| Complexity | Task Type | Estimated Duration |
|------------|-----------|-------------------|
| Low | Research/Explore | 10-20 minutes |
| Low | Bug fix | 15-30 minutes |
| Medium | Design task | 30-60 minutes |
| Medium | Feature implementation | 45-90 minutes |
| High | Architecture | 45-90 minutes |
| High | Major refactoring | 90-180 minutes |
| Critical | Production debugging | 15-45 minutes |
| Critical | Security audit | 30-60 minutes |

**Parallel Work Multiplier**: When N agents work in parallel, total time ≈ Max(individual times), not Sum(individual times).

---

## Best Practices from Real Scenarios

1. **Create epics for complex work**: Any task requiring 3+ agents benefits from epic structure
2. **Delegate immediately**: Don't wait - create follow-up tasks as soon as you identify them
3. **Parallel when possible**: Use `--related` for independent work, execute simultaneously
4. **Document in task comments**: Comments become team knowledge - be thorough
5. **Use priorities correctly**: P0 for incidents, P1 for important features, P2+ for improvements
6. **Close tasks promptly**: Completed tasks should be closed to keep boards clean
7. **Link dependencies carefully**: Only block when truly necessary - over-blocking kills parallelization

---

**Next**: See [BEADS_HIERARCHY.md](./BEADS_HIERARCHY.md) for task structure patterns and [BEADS_WORKFLOWS.md](./BEADS_WORKFLOWS.md) for agent-specific workflows.
