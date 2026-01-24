# Beads Workflows: Agent-Specific Operational Patterns

**Version**: 1.0  
**Last Updated**: 2026-01-23  
**Purpose**: Step-by-step workflows for each of the 14 agents using Beads

---

## Overview

This document provides **agent-specific workflows** showing exactly how each agent should use Beads in their day-to-day work. Each workflow includes:

- Step-by-step process
- Specific `bd` commands
- Decision points
- Coordination patterns
- Common scenarios

Use this as an **operational playbook** for each agent role.

---

## Primary Agents

### Orchestrator Workflow

**Role**: Multi-agent coordinator and project manager  
**Model**: Claude Opus  
**Focus**: Strategy, delegation, monitoring, synthesis

#### Standard Workflow

```
1. RECEIVE REQUEST
   ↓
2. ANALYZE SCOPE
   ↓
3. CREATE EPIC (if complex)
   ↓
4. BREAK INTO SUBTASKS
   ↓
5. SET DEPENDENCIES
   ↓
6. DELEGATE TO SPECIALISTS
   ↓
7. MONITOR PROGRESS
   ↓
8. RESOLVE BLOCKERS
   ↓
9. SYNTHESIZE RESULTS
   ↓
10. VERIFY & CLOSE
```

#### Detailed Steps

**Step 1: Receive Request**
- User describes desired feature/fix
- Orchestrator asks clarifying questions
- Determines complexity level

**Step 2: Analyze Scope**
```bash
# Check existing work
bd list --search "authentication"
bd list --tag feature --status in-progress

# Assess complexity
- Simple (<2 hours, 1 agent) → Delegate directly
- Medium (2-4 hours, 2-3 agents) → Create coordinated tasks
- Complex (>4 hours, 3+ agents) → Create epic
```

**Step 3: Create Epic (for complex work)**
```bash
bd create "Epic: Add two-factor authentication" \
  --priority P1 \
  --tag epic,feature,security \
  --description "User request: Enable 2FA for all accounts. 
  Requirements: SMS and TOTP support, backup codes, admin controls."
```

**Step 4: Break Into Subtasks**
```bash
# Design phase
bd create "Design 2FA architecture and flow" \
  --epic 100 \
  --assign architect \
  --priority P1 \
  --tag architecture

# Output: Created task 101

# Research if needed
bd create "Research 2FA libraries and best practices" \
  --epic 100 \
  --assign research \
  --priority P1 \
  --tag research

# Output: Created task 102

# Implementation tasks
bd create "Implement TOTP backend" \
  --epic 100 \
  --assign build \
  --priority P1 \
  --tag implementation

# Output: Created task 103

bd create "Implement SMS backend" \
  --epic 100 \
  --assign build \
  --priority P1 \
  --tag implementation

# Output: Created task 104

bd create "Add 2FA to login flow" \
  --epic 100 \
  --assign build \
  --priority P1 \
  --tag implementation

# Output: Created task 105

# QA tasks
bd create "Security audit 2FA implementation" \
  --epic 100 \
  --assign security \
  --priority P1 \
  --tag security,review

# Output: Created task 106

bd create "Test 2FA flows end-to-end" \
  --epic 100 \
  --assign test \
  --priority P1 \
  --tag testing

# Output: Created task 107

# Documentation
bd create "Document 2FA setup and usage" \
  --epic 100 \
  --assign document \
  --priority P1 \
  --tag documentation

# Output: Created task 108
```

**Step 5: Set Dependencies**
```bash
# Design + Research must complete first
bd dep add 101 --blocks 103 104 105
bd dep add 102 --blocks 103 104  # Research informs implementation

# Implementation before QA
bd dep add 103 104 105 --blocks 106 107

# QA before docs
bd dep add 106 107 --blocks 108

# Mark initial tasks ready
bd ready 101 102
```

**Step 6: Delegate to Specialists**
```bash
# Already done via --assign in create commands
# Verify assignments
bd show 100

# Output shows all subtasks with assignees
```

**Step 7: Monitor Progress**
```bash
# Check epic status
bd show 100

# Check agent workloads
bd list --assignee architect --status in-progress
bd list --assignee build --status ready
bd list --assignee security --status backlog

# Check for blocked tasks
bd list --status backlog --epic 100

# Daily standup view
bd list --epic 100 --status in-progress
```

**Step 8: Resolve Blockers**
```bash
# Scenario: Security agent finds issue during audit

# Security creates blocker task
bd show 106 --comments
# Comment: "Found SQL injection vulnerability in SMS flow. 
#           Created fix task #109."

# Orchestrator re-prioritizes
bd update 109 --priority P0
bd dep add 109 --blocks 107  # Fix before final testing

# Notify build agent (in practice, agent checks bd ready)
bd ready --assign build --priority P0
# Shows task 109 as urgent
```

**Step 9: Synthesize Results**
```bash
# When all subtasks done, review completeness
bd show 100

# Review key deliverables
bd show 101 --comments  # Architecture decisions
bd show 106 --comments  # Security findings
bd show 107 --comments  # Test results
bd show 108 --comments  # Documentation location

# Verify feature works end-to-end
# (May create final integration test task if needed)
```

**Step 10: Verify & Close**
```bash
# Update epic status
bd update 100 --status done

# Close all tasks
bd close 101 102 103 104 105 106 107 108
bd close 100

# Report to user
echo "2FA feature complete. See task #100 for details."
```

#### Decision Points

**Q: When to create an epic vs standalone task?**
- Epic: 3+ agents, multiple phases, >4 hours total work
- Standalone: 1-2 agents, single phase, <4 hours

**Q: How to handle changing requirements mid-epic?**
```bash
# User: "Actually, also add hardware key support"
bd create "Add hardware key (WebAuthn) support" \
  --epic 100 \
  --assign build \
  --priority P1
bd dep add 105 --blocks 110  # After login flow integration
```

**Q: What if an agent is blocked on external dependency?**
```bash
# Mark task as blocked with reason
bd update 104 --status backlog \
  --description "Blocked: Waiting for Twilio API credentials from ops team"

# Create tracking task
bd create "Obtain Twilio API credentials" \
  --priority P1 \
  --tag external,ops
bd dep add 111 --blocks 104
```

---

### Architect Workflow

**Role**: System designer and technical planner  
**Model**: Claude Sonnet  
**Focus**: Design, architecture, technical decisions

#### Standard Workflow

```
1. GET DESIGN TASK
   ↓
2. RESEARCH CONTEXT
   ↓
3. DESIGN SOLUTION
   ↓
4. DOCUMENT ARCHITECTURE
   ↓
5. CREATE IMPLEMENTATION TASKS
   ↓
6. MARK DESIGN COMPLETE
```

#### Detailed Steps

**Step 1: Get Design Task**
```bash
# Check for design work
bd ready --assign architect

# Output:
# 101: Design 2FA architecture and flow [P1]

# Pick task
bd update 101 --status in-progress
```

**Step 2: Research Context**
```bash
# Read epic description
bd show 100

# Check related work
bd list --tag authentication
bd list --search "security"

# May create research subtask if needed
bd create "Research existing auth architecture" \
  --epic 101 \
  --assign research \
  --priority P1

# Or do quick exploration yourself
# - Read current auth code
# - Review security requirements
# - Check industry best practices
```

**Step 3: Design Solution**
```
Design considerations:
- Architecture patterns
- Data models
- API contracts
- Security considerations
- Performance implications
- Migration strategy

Create: docs/architecture/2fa-design.md
```

**Step 4: Document Architecture**
```bash
# Create architecture document
# File: docs/architecture/2fa-design.md

# Update task with location
bd update 101 --description "Architecture design complete.

Design Doc: docs/architecture/2fa-design.md

Key Decisions:
1. TOTP: Use standard RFC 6238 with 30-second windows
2. SMS: Twilio integration, rate-limited to 5/hour
3. Backup codes: 10 single-use codes, bcrypt hashed
4. Storage: New users_2fa table with encrypted secrets
5. Flow: Optional during login, mandatory for sensitive actions

Implementation breakdown:
- Backend models and APIs (Build)
- Frontend components (Build)
- SMS integration (Build)
- Security review (Security)
- Testing (Test)

Estimated: 8-10 hours total implementation"
```

**Step 5: Create Implementation Tasks**
```bash
# Often done by Orchestrator, but Architect can refine
# Add implementation notes to existing tasks
bd update 103 --description "Implement TOTP per RFC 6238.
See docs/architecture/2fa-design.md section 3.1.
Required:
- Generate secrets (crypto random, base32 encoded)
- Validate tokens (30-second window ± 1)
- QR code generation for mobile apps
- Secret encryption at rest"

bd update 104 --description "Implement SMS via Twilio API.
See docs/architecture/2fa-design.md section 3.2.
Required:
- Twilio SDK integration
- Rate limiting (5 codes/hour per user)
- Phone number validation
- Template: 'Your code is {code}. Valid for 5 minutes.'"
```

**Step 6: Mark Design Complete**
```bash
bd done 101 --comment "Architecture design complete.
Document: docs/architecture/2fa-design.md

Summary:
- TOTP + SMS + backup codes approach
- New users_2fa table added to schema
- API endpoints designed: /api/2fa/setup, /api/2fa/verify
- Security: Encrypted secrets, rate limiting, audit logging
- Migration: Optional rollout, backward compatible

Ready for implementation. All implementation tasks updated with specs."

# Output:
# Task 101 completed
# Tasks unblocked: 103, 104, 105 (if research also done)
```

#### Decision Points

**Q: What if requirements are unclear?**
```bash
# Create clarification task for orchestrator
bd create "Clarify 2FA requirements: mandatory vs optional?" \
  --assign orchestrator \
  --priority P1 \
  --tag question

bd dep add 112 --blocks 101  # Can't design until clarified
bd update 101 --status backlog
```

**Q: Design reveals new complexity?**
```bash
# Update epic with findings
bd update 100 --description "Epic scope increased: 
Need to add account recovery flow for lost 2FA devices.
Creating additional task."

bd create "Design 2FA account recovery process" \
  --epic 100 \
  --assign architect \
  --priority P1
```

**Q: Multiple design approaches - which to choose?**
```
Document alternatives in architecture doc:
- Approach A: [pros/cons]
- Approach B: [pros/cons]
**DECISION: Approach A** because [reasoning]

Record in task comments for transparency.
```

---

### Build Workflow

**Role**: Code implementation specialist  
**Model**: Claude Sonnet  
**Focus**: Writing production code

#### Standard Workflow

```
1. QUERY READY TASKS
   ↓
2. PICK HIGHEST PRIORITY
   ↓
3. READ DESIGN SPECS
   ↓
4. IMPLEMENT CODE
   ↓
5. CREATE FOLLOW-UP TASKS
   ↓
6. MARK COMPLETE
```

#### Detailed Steps

**Step 1: Query Ready Tasks**
```bash
# Check for ready implementation work
bd ready --assign build --priority P0,P1

# Output:
# 103: Implement TOTP backend [P1]
# 104: Implement SMS backend [P1]
# 105: Add 2FA to login flow [P1]
```

**Step 2: Pick Highest Priority**
```bash
# Check dependencies
bd show 103 --deps

# Output:
# Task 103: Implement TOTP backend
# Status: ready
# Blocked by: 101 [done], 102 [done]
# Blocks: 106, 107

# Start work
bd update 103 --status in-progress
```

**Step 3: Read Design Specs**
```bash
# Read design doc
bd show 101 --comments
# Points to: docs/architecture/2fa-design.md

# Read task description
bd show 103
# Has implementation details from Architect

# Check related tasks for context
bd show 104  # SMS implementation
bd show 105  # Login flow integration
```

**Step 4: Implement Code**
```
Implement:
- lib/auth/totp.rs (TOTP logic)
- models/user_2fa.rs (data model)
- api/2fa/setup.rs (setup endpoint)
- api/2fa/verify.rs (verify endpoint)

Test locally:
- cargo test
- Manual testing with authenticator app
```

**Step 5: Create Follow-Up Tasks**
```bash
# Delegate testing
bd create "Unit tests for TOTP implementation" \
  --assign test \
  --priority P1 \
  --tag testing

# Output: Created task 113

bd dep add 103 --blocks 113

# Discovered edge case
bd create "Handle TOTP clock skew (± 1 window)" \
  --assign build \
  --priority P2 \
  --tag enhancement

# Output: Created task 114

# Document API
bd create "Document TOTP API endpoints" \
  --assign document \
  --priority P1 \
  --tag documentation

# Output: Created task 115

bd dep add 103 --blocks 115
```

**Step 6: Mark Complete**
```bash
bd done 103 --comment "TOTP backend implementation complete.

Files:
- lib/auth/totp.rs (core logic)
- models/user_2fa.rs (database model)
- api/2fa/setup.rs (setup endpoint)
- api/2fa/verify.rs (verification endpoint)
- migrations/20260123_add_2fa_table.sql

Features:
✓ RFC 6238 compliant TOTP generation
✓ 30-second time window with ± 1 skew tolerance
✓ QR code generation for mobile setup
✓ Encrypted secret storage
✓ Rate limiting (10 attempts/hour)

Testing:
✓ Tested with Google Authenticator
✓ Tested with Authy
✓ Local unit tests passing

Follow-ups created:
- #113: Unit tests
- #114: Enhanced clock skew handling
- #115: API documentation

Ready for security review (#106)."

# Output:
# Task 103 completed
# Tasks unblocked: 113, 115 (if all other blockers done)
```

#### Decision Points

**Q: Blocker discovered during implementation?**
```bash
# Example: Need database migration approved
bd create "DBA review: 2FA table schema" \
  --priority P0 \
  --tag database,approval

bd dep add 116 --blocks 103
bd update 103 --status backlog \
  --description "Blocked: Waiting for DBA approval of schema (#116)"
```

**Q: Implementation reveals design flaw?**
```bash
# Alert architect
bd create "Architecture issue: TOTP secret regeneration" \
  --assign architect \
  --priority P1 \
  --tag architecture,issue \
  --description "Current design doesn't handle secret regeneration if user loses device. Need recovery flow."

# Mark original task blocked
bd dep add 117 --blocks 103
bd update 103 --status backlog
```

**Q: Found bug in existing code?**
```bash
# Create fix task
bd create "Fix auth session expiration bug" \
  --priority P1 \
  --tag bug \
  --assign fix

# Not blocking current work, continue
```

---

## Subagents (Quick Workflows)

### Plan Agent

**Role**: Task breakdown specialist  
**Model**: Claude Haiku (fast)  
**Focus**: Breaking epics into actionable tasks

**Workflow**:
```
1. GET PLANNING TASK → bd ready --assign plan
2. ANALYZE EPIC → bd show <epic-id>
3. BREAK INTO TASKS → bd create "Task 1" --epic <id>
                       bd create "Task 2" --epic <id>
4. SET DEPENDENCIES → bd dep add X --blocks Y
5. ESTIMATE EFFORT → Add to task descriptions
6. MARK COMPLETE → bd done <id> --comment "Created N subtasks"
```

**Example**:
```bash
bd ready --assign plan
# Output: 120: Break down export feature epic

bd show 120
# Reads epic requirements

# Create subtasks
bd create "Design export data model" --epic 120 --assign architect
bd create "Implement CSV export" --epic 120 --assign build
bd create "Implement JSON export" --epic 120 --assign build
bd create "Add export UI controls" --epic 120 --assign build
bd create "Test all export formats" --epic 120 --assign test

# Set dependencies
bd dep add 121 --blocks 122 123 124  # Design before impl
bd dep add 122 123 124 --blocks 125  # Impl before test

bd done 120 --comment "Broken into 5 tasks. Estimated 6-8 hours total."
```

---

### Review Agent

**Role**: Code quality and QA specialist  
**Model**: Claude Sonnet  
**Focus**: Code review, quality checks

**Workflow**:
```
1. GET REVIEW TASK → bd ready --assign review
2. REVIEW CODE → Check implementation quality
3. DOCUMENT FINDINGS → Create fix tasks if needed
4. APPROVE OR REJECT → bd done with verdict
```

**Example**:
```bash
bd ready --assign review
# Output: 126: Code review for 2FA implementation

bd update 126 --status in-progress

# Review code in lib/auth/totp.rs
# Found issues:
bd create "Fix: TOTP secrets not cryptographically random" \
  --priority P0 \
  --tag bug,security \
  --assign fix

bd create "Refactor: Extract QR code generation to separate module" \
  --priority P2 \
  --tag refactor

bd done 126 --comment "Code review complete.

FINDINGS:
🔴 CRITICAL: Secrets using math/rand instead of crypto/rand (#127)
🟡 Suggestion: QR code generation should be separate module (#128)
✓ Overall code quality good
✓ Error handling appropriate
✓ Tests comprehensive

VERDICT: DO NOT MERGE until #127 fixed. #128 optional.

Re-review after #127 complete."
```

---

### Test Agent

**Role**: Testing and verification specialist  
**Model**: Claude Sonnet  
**Focus**: Writing and running tests

**Workflow**:
```
1. GET TEST TASK → bd ready --assign test
2. READ IMPLEMENTATION → Understand what to test
3. WRITE TESTS → Unit, integration, e2e
4. VERIFY COVERAGE → Aim for >80%
5. MARK COMPLETE → bd done with results
```

**Example**:
```bash
bd ready --assign test
# Output: 107: Test 2FA flows end-to-end

bd update 107 --status in-progress

# Write tests
# - tests/integration/2fa_test.rs
# - Test setup flow
# - Test verification flow
# - Test failure cases
# - Test rate limiting

bd done 107 --comment "End-to-end testing complete.

TEST RESULTS:
✓ TOTP setup flow: 15 tests, all passing
✓ SMS setup flow: 12 tests, all passing
✓ Verification flow: 20 tests, all passing
✓ Failure cases: 10 tests, all passing
✓ Rate limiting: 8 tests, all passing

COVERAGE: 94% (target: 80%)

FILES:
- tests/integration/2fa_totp_test.rs
- tests/integration/2fa_sms_test.rs
- tests/integration/2fa_flows_test.rs

All tests passing. Ready for production."
```

---

### Security Agent

**Role**: Security analysis and hardening  
**Model**: Claude Sonnet  
**Focus**: Finding vulnerabilities, security review

**Workflow**:
```
1. GET SECURITY TASK → bd ready --assign security
2. SECURITY AUDIT → Check for vulnerabilities
3. CREATE FIX TASKS → For each finding
4. APPROVE OR BLOCK → bd done with verdict
```

**Example**:
```bash
bd ready --assign security
# Output: 106: Security audit 2FA implementation

bd update 106 --status in-progress

# Audit checklist:
# - Secret storage encryption
# - Rate limiting
# - Input validation
# - Session management
# - Crypto primitives

# Found issues
bd create "Fix: Add constant-time comparison for TOTP tokens" \
  --priority P0 \
  --tag security,timing-attack

bd create "Enhance: Add audit logging for 2FA events" \
  --priority P1 \
  --tag security,logging

bd done 106 --comment "Security audit complete.

CRITICAL FINDINGS:
🔴 P0: Timing attack possible in token comparison (#129)
   Use constant-time comparison to prevent timing side-channel

RECOMMENDATIONS:
🟡 P1: Add audit logging for setup/verification/failures (#130)
✓ Secret storage: AES-256 encrypted ✓
✓ Rate limiting: Implemented correctly ✓
✓ Input validation: Comprehensive ✓
✓ Crypto: Using proper libraries ✓

VERDICT: BLOCK deployment until #129 fixed.
Re-audit after fix complete."
```

---

### Document Agent

**Role**: Technical documentation specialist  
**Model**: Claude Sonnet  
**Focus**: Creating clear, comprehensive docs

**Workflow**:
```
1. GET DOCS TASK → bd ready --assign document
2. READ IMPLEMENTATION → Understand what to document
3. WRITE DOCUMENTATION → User guides, API docs
4. ADD EXAMPLES → Code samples, configs
5. MARK COMPLETE → bd done with doc locations
```

**Example**:
```bash
bd ready --assign document
# Output: 108: Document 2FA setup and usage

bd update 108 --status in-progress

# Create docs:
# - docs/user-guide/2fa-setup.md
# - docs/api/2fa-endpoints.md
# - Include screenshots
# - Include curl examples
# - Include troubleshooting

bd done 108 --comment "Documentation complete.

CREATED:
📄 docs/user-guide/2fa-setup.md
   - End-user setup instructions
   - Screenshots for TOTP and SMS flows
   - Troubleshooting common issues

📄 docs/api/2fa-endpoints.md
   - API reference for /api/2fa/setup
   - API reference for /api/2fa/verify
   - Request/response examples
   - Error codes

📄 docs/admin/2fa-configuration.md
   - Admin configuration options
   - Twilio setup
   - Rate limiting configuration

All examples tested and verified.
Added to main docs index."
```

---

### Debug Agent

**Role**: Systematic problem solver  
**Model**: Claude Sonnet  
**Focus**: Root cause analysis

**Workflow**:
```
1. GET BUG REPORT → bd ready --assign debug
2. REPRODUCE ISSUE → Verify bug exists
3. INVESTIGATE ROOT CAUSE → Logs, traces, debugging
4. DOCUMENT FINDINGS → Update task description
5. CREATE FIX TASK → Delegate to Fix agent
6. MARK COMPLETE → bd done with analysis
```

**Example**:
```bash
bd ready --assign debug
# Output: 131: Debug: 2FA tokens sometimes fail validation

bd update 131 --status in-progress

# Investigation:
# - Check logs
# - Reproduce issue
# - Test clock synchronization
# - Review TOTP implementation

bd update 131 --description "ROOT CAUSE IDENTIFIED:

Server time and user device time drift >90 seconds causes validation failure.
Current implementation uses ± 1 time window (30 seconds each) = 90 second tolerance.

EVIDENCE:
- Logs show failures when server-client time delta >90s
- Reproduced by setting system clock +120 seconds
- TOTP RFC 6238 recommends ± 2 windows minimum

SOLUTION:
Increase time window tolerance from ± 1 to ± 2 windows (180 second total tolerance)."

bd create "Fix: Increase TOTP time window tolerance to ± 2" \
  --priority P1 \
  --tag bug,fix \
  --assign fix

bd dep add 131 --blocks 132

bd done 131 --comment "Root cause: Insufficient time window tolerance.
Analysis in task description.
Created fix task #132."
```

---

### Research Agent

**Role**: Codebase exploration and investigation  
**Model**: Claude Haiku (fast)  
**Focus**: Quick discovery and fact-finding

**Workflow**:
```
1. GET RESEARCH TASK → bd ready --assign research
2. EXPLORE CODEBASE → Find relevant files/patterns
3. DOCUMENT FINDINGS → Write summary
4. MARK COMPLETE → bd done with findings
```

**Example**:
```bash
bd ready --assign research
# Output: 102: Research 2FA libraries and best practices

bd update 102 --status in-progress

# Research:
# - Survey available Rust TOTP libraries
# - Check security best practices
# - Review existing auth implementation
# - Industry standards (RFC 6238)

bd done 102 --comment "Research complete.

TOTP LIBRARIES:
1. totp-rs ⭐ Recommended
   - RFC 6238 compliant
   - Well maintained
   - Good documentation
2. oath - Alternative but less active

BEST PRACTICES:
- Use ± 2 time windows (180s tolerance)
- Encrypt secrets at rest (AES-256)
- Rate limit verification attempts
- Support backup codes
- QR code generation for easy setup

CURRENT AUTH SYSTEM:
- Located in: lib/auth/
- Uses JWT tokens
- Session management in lib/session/
- Easy integration point identified

RECOMMENDATION: Use totp-rs library, integrate at lib/auth/ level."
```

---

### Optimize Agent

**Role**: Performance optimization specialist  
**Model**: Claude Sonnet  
**Focus**: Improving speed, reducing resource usage

**Workflow**:
```
1. GET OPTIMIZATION TASK → bd ready --assign optimize
2. BENCHMARK CURRENT → Measure baseline
3. IDENTIFY BOTTLENECKS → Profile, analyze
4. IMPLEMENT OPTIMIZATION → Make improvements
5. BENCHMARK AFTER → Verify improvement
6. MARK COMPLETE → bd done with metrics
```

**Example**:
```bash
bd ready --assign optimize
# Output: 133: Optimize 2FA database queries

bd update 133 --status in-progress

# Benchmark current:
# - Measure query times
# - Check query plans
# - Identify slow queries

# Optimize:
# - Add index on users_2fa.user_id
# - Add index on users_2fa.enabled
# - Optimize lookup query

bd done 133 --comment "Database optimization complete.

BEFORE:
- 2FA lookup query: 45ms average
- Table scan on 100k users

OPTIMIZATIONS:
- Added index on users_2fa.user_id
- Added index on users_2fa.enabled
- Rewrote query to use covering index

AFTER:
- 2FA lookup query: 2ms average (22x faster)
- Index seek instead of table scan

MIGRATION:
- migrations/20260123_add_2fa_indexes.sql

Performance target met."
```

---

### Refactor Agent

**Role**: Code quality and maintainability  
**Model**: Claude Sonnet  
**Focus**: Improving code structure

**Workflow**:
```
1. GET REFACTOR TASK → bd ready --assign refactor
2. ANALYZE CODE → Identify tech debt
3. PLAN REFACTORING → Design improvements
4. REFACTOR → Improve structure
5. VERIFY TESTS → Ensure behavior unchanged
6. MARK COMPLETE → bd done with changes
```

**Example**:
```bash
bd ready --assign refactor
# Output: 134: Refactor 2FA code for better testability

bd update 134 --status in-progress

# Refactoring:
# - Extract interfaces
# - Dependency injection
# - Separate concerns
# - Improve naming

bd done 134 --comment "Refactoring complete.

CHANGES:
- Extracted TotpProvider trait for dependency injection
- Separated secret generation from validation logic
- Moved QR code generation to separate module
- Improved function naming for clarity
- Added builder pattern for TOTP config

BENEFITS:
- 100% unit testable (was 60%)
- Easy to mock for testing
- Clearer separation of concerns
- More flexible configuration

FILES:
- lib/auth/totp/provider.rs (new interface)
- lib/auth/totp/generator.rs (secret generation)
- lib/auth/totp/validator.rs (token validation)
- lib/auth/totp/qr.rs (QR code generation)

All tests passing. No behavior changes."
```

---

### Nix-Specialist Agent

**Role**: NixOS configuration expert  
**Model**: Claude Sonnet  
**Focus**: NixOS modules, system configuration

**Workflow**:
```
1. GET NIXOS TASK → bd ready --assign nix-specialist
2. DESIGN MODULE → Plan module structure
3. IMPLEMENT MODULE → Write Nix code
4. TEST LOCALLY → nixos-rebuild test
5. MARK COMPLETE → bd done with module location
```

**Example**:
```bash
bd ready --assign nix-specialist
# Output: 135: Create NixOS module for 2FA service

bd update 135 --status in-progress

# Create module:
# - modules/services/2fa/default.nix
# - Define options
# - Configure systemd service
# - Add to module list

bd done 135 --comment "NixOS module complete.

MODULE: modules/services/2fa/default.nix

OPTIONS:
- services.twofa.enable (bool)
- services.twofa.port (int, default 3000)
- services.twofa.database.host (string)
- services.twofa.twilio.accountSid (string)
- services.twofa.twilio.authToken (secretFile)

FEATURES:
✓ Systemd service configuration
✓ Automatic database migrations
✓ Secret management via sops-nix
✓ Nginx reverse proxy config
✓ Firewall rules

TESTING:
Tested with: nixos-rebuild test
Service starts correctly
All options validated

USAGE:
{
  services.twofa = {
    enable = true;
    port = 3000;
    database.host = \"localhost\";
  };
}"
```

---

### Fix Agent

**Role**: Fast bug fix specialist  
**Model**: Claude Haiku (fast)  
**Focus**: Quick, targeted fixes

**Workflow**:
```
1. GET FIX TASK → bd ready --assign fix --priority P0,P1
2. READ BUG ANALYSIS → Understand root cause
3. IMPLEMENT FIX → Quick, focused change
4. TEST FIX → Verify it works
5. MARK COMPLETE → bd done with fix description
```

**Example**:
```bash
bd ready --assign fix --priority P0
# Output: 127: Fix: TOTP secrets not cryptographically random

bd update 127 --status in-progress

# Fix:
# - Change rand::random() to crypto/rand
# - Update dependencies
# - Test secret generation

bd done 127 --comment "Fix applied.

ISSUE: Using math/rand instead of crypto/rand for secret generation
RISK: Predictable secrets → security vulnerability

FIX:
- Updated lib/auth/totp.rs:42
- Changed: rand::thread_rng().gen() → OsRng.gen()
- Added: use rand::rngs::OsRng;

VERIFICATION:
✓ Secrets now cryptographically random
✓ All tests passing
✓ Generated 1000 secrets, verified entropy

Commit: abc123
Ready for security re-review."
```

---

### Explore Agent

**Role**: Fast codebase discovery  
**Model**: Claude Haiku (fast)  
**Focus**: Quick file/pattern discovery

**Workflow**:
```
1. GET EXPLORATION TASK → bd ready --assign explore
2. SEARCH CODEBASE → Find relevant files
3. DOCUMENT FINDINGS → List locations
4. MARK COMPLETE → bd done with file list
```

**Example**:
```bash
bd ready --assign explore
# Output: 136: Find all authentication-related files

bd update 136 --status in-progress

# Search:
# - grep -r "auth" --include="*.rs"
# - Find all relevant files
# - Map structure

bd done 136 --comment "Exploration complete.

AUTHENTICATION FILES:
Core:
- lib/auth/mod.rs (main auth module)
- lib/auth/jwt.rs (JWT token handling)
- lib/auth/session.rs (session management)
- lib/auth/password.rs (password hashing)

2FA (new):
- lib/auth/totp.rs (TOTP implementation)
- lib/auth/sms.rs (SMS provider)

API:
- api/auth/login.rs (login endpoint)
- api/auth/logout.rs (logout endpoint)
- api/2fa/setup.rs (2FA setup)
- api/2fa/verify.rs (2FA verification)

Models:
- models/user.rs (user model)
- models/session.rs (session model)
- models/user_2fa.rs (2FA model)

Tests:
- tests/auth/*.rs (15 test files)

TOTAL: 23 files related to authentication"
```

---

### General Agent

**Role**: Multi-purpose fallback agent  
**Model**: Claude Sonnet  
**Focus**: Miscellaneous work

**Workflow**:
```
1. GET UNASSIGNED TASK → bd ready --assignee none
2. ASSESS TASK → Determine what's needed
3. DO THE WORK → Implementation varies
4. MARK COMPLETE → bd done with details
```

**Example**:
```bash
bd ready --assignee none
# Output: 137: Update project README with 2FA feature

bd update 137 --assign general --status in-progress

# Update README:
# - Add 2FA to features list
# - Update screenshots
# - Add setup instructions link

bd done 137 --comment "README updated.

CHANGES:
- Added 2FA to features list
- Added screenshot of 2FA setup flow
- Added link to docs/user-guide/2fa-setup.md
- Updated \"Getting Started\" section

File: README.md"
```

---

## Cross-Agent Coordination Patterns

### Pattern 1: Hand-off Chain
```
Architect designs → Build implements → Test verifies → Document writes

Each agent:
1. bd ready --assign <agent>
2. Do work
3. bd done <task> --comment "..."
4. Next agent automatically sees task as ready
```

### Pattern 2: Parallel Split
```
Orchestrator creates epic
├─→ Build task 1 (ready)
├─→ Build task 2 (ready)
└─→ Build task 3 (ready)

All 3 build tasks can progress simultaneously.
```

### Pattern 3: Review Cycle
```
1. Build completes task
2. bd create "Review task #X" --assign review
3. Review finds issues
4. bd create "Fix issues from review #Y" --assign fix
5. Fix completes
6. Review re-checks
7. Review approves
```

### Pattern 4: Emergency Escalation
```
1. User reports P0 bug
2. bd create "CRITICAL: ..." --priority P0 --assign debug
3. Debug finds root cause
4. bd create "Fix: ..." --priority P0 --assign fix
5. Fix implements
6. bd create "Verify fix" --priority P0 --assign test
7. Test confirms
8. All agents see P0 tasks first in bd ready
```

---

## Best Practices Summary

### For All Agents

1. **Start every session with**: `bd ready --assign <your-agent>`
2. **Mark tasks in-progress**: `bd update X --status in-progress`
3. **Create follow-ups**: Don't let work fall through cracks
4. **Complete with details**: `bd done X --comment "detailed summary"`
5. **Respect dependencies**: Don't start blocked tasks

### For Orchestrator

1. Create epics for complex work
2. Set dependencies thoughtfully
3. Monitor daily: `bd show <epic-id>`
4. Resolve blockers quickly
5. Close completed work promptly

### For Specialists

1. Stay in your lane (delegate out of scope)
2. Read task descriptions carefully
3. Update task descriptions with findings
4. Link related work
5. Provide detailed completion comments

---

**Conclusion**: These workflows turn 14 independent AI agents into a coordinated, persistent development team through Beads' shared memory system.

---

**Related Docs**:
- [Main Guide](./BEADS_AGENT_GUIDE.md) - Core concepts
- [Examples](./BEADS_EXAMPLES.md) - Real-world scenarios
- [Hierarchy](./BEADS_HIERARCHY.md) - Task structure patterns
