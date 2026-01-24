# River WM Suspend/Resume Issue - Research Documentation

This directory contains comprehensive research and implementation guides for fixing the river tiling manager issue after system suspend/resume in NixOS.

## Documents Overview

### 1. **river-suspend-issue-analysis.md** (498 lines)
**Complete technical analysis** - Read this first for deep understanding.

Contains:
- Current river configuration analysis with code locations and line numbers
- Detailed root cause analysis (5 different failure mechanisms)
- Explanation of what "broken tiling" means (8 symptoms)
- Known Wayland/wlroots suspend patterns
- 5 different solution approaches with comprehensive pros/cons analysis
- Recommended implementation strategy
- Known upstream issues and alternative architectures
- Testing and rollback procedures

**Best for:** Understanding why the issue occurs and what needs fixing

---

### 2. **RIVER-SUSPEND-EXECUTIVE-SUMMARY.md** (147 lines)
**High-level overview** - Read this before diving into implementation.

Contains:
- Problem statement and root cause
- 8 observable symptoms
- 4 configuration issues identified
- Technical diagram of suspend/resume failure
- Recommended solution (Systemd Resume Hook)
- 4 implementation phases with priorities
- Code changes overview (~40 lines total)
- Complete testing checklist
- Timeline: ~2-3 hours effort
- Risk assessment table
- Next steps and references

**Best for:** Managers, tech leads, quick understanding of scope

---

### 3. **RIVER-SUSPEND-IMPLEMENTATION-GUIDE.md** (404 lines)
**Ready-to-use code and instructions** - Use this to implement the fix.

Contains:
- 5 implementation phases (1 required, 4 optional)
- Complete code snippets ready to paste
- Exact file locations and line numbers
- Clear explanation of why each code snippet works
- Step-by-step installation instructions
- Comprehensive testing procedures for each phase
- Troubleshooting guide with diagnostics
- Rollback instructions
- Performance impact analysis
- Code placement reference diagram
- Complete validation checklist

**Best for:** Developers implementing the fix

---

## Issue Status

**Created:** January 24, 2026  
**Research Status:** ✅ Complete  
**Implementation Status:** ⏳ Ready to implement  
**Beads Issue:** `system-yoj` (P0 - High Priority)

---

## Key Findings

### Root Cause
The **wideriver daemon** (window layout manager) loses IPC connection to River after suspend-resume due to Wayland protocol state corruption. River process survives but becomes non-functional.

### Primary Symptoms
- Windows stop tiling (stay floating)
- Layout commands don't work (Super+T, Super+M unresponsive)
- Multi-monitor config not restored
- Service processes still running but broken

### Recommended Solution
**Systemd user service resume hook** that:
1. Detects wake-up from suspend
2. Waits for GPU to initialize (~1.5 seconds)
3. Force-reconnects wideriver via `riverctl default-layout wideriver`
4. Reloads display configuration via Kanshi
5. Notifies user of restore

### Implementation Effort
- **Phase 1 (Quick fix):** 1-2 lines in `modules/home/services.nix`
- **Phase 2-4 (Full solution):** ~40 lines total across 4 files
- **Testing:** 30 minutes for complete validation
- **Total effort:** 2-3 hours including testing

### Risk Level
**LOW** - All changes are additive (no modifications to core River/wideriver)

---

## Configuration Files Affected

| File | Changes | Priority |
|------|---------|----------|
| `modules/home/services.nix` | +20 lines (Resume hook) | 🔴 Required |
| `modules/home/river.nix` | +10 lines (Health monitor) | 🟡 Recommended |
| `modules/home/river.nix` | +4 lines (Manual recovery key) | 🟢 Optional |
| `modules/home/shell.nix` | +1 line (GPU delay) | 🟢 Optional |
| `modules/system/graphics.nix` | +1 line (NVIDIA power mgmt) | 🟢 Optional |

---

## How to Use This Research

### For Implementers
1. Read **RIVER-SUSPEND-EXECUTIVE-SUMMARY.md** (5 min)
2. Read relevant sections of **river-suspend-issue-analysis.md** (10 min)
3. Follow **RIVER-SUSPEND-IMPLEMENTATION-GUIDE.md** step-by-step (60 min)
4. Run testing checklist (30 min)
5. Commit changes with reference to research

### For Code Reviewers
1. Read **RIVER-SUSPEND-EXECUTIVE-SUMMARY.md** 
2. Review code changes against **RIVER-SUSPEND-IMPLEMENTATION-GUIDE.md**
3. Verify all phases completed per implementation plan
4. Check testing results against provided checklist

### For Debugging Issues
1. Check **RIVER-SUSPEND-ISSUE-ANALYSIS.md** section 8 (Troubleshooting)
2. Refer to **RIVER-SUSPEND-IMPLEMENTATION-GUIDE.md** (Troubleshooting section)
3. Use diagnostic commands provided
4. Check systemd logs: `journalctl --user -u river-resume-hook -n 50`

---

## Quick Implementation Checklist

- [ ] Read RIVER-SUSPEND-EXECUTIVE-SUMMARY.md
- [ ] Read relevant parts of Implementation Guide
- [ ] Add resume hook service to `modules/home/services.nix`
- [ ] (Optional) Add health monitor to `modules/home/river.nix`
- [ ] (Optional) Add manual recovery key to `modules/home/river.nix`
- [ ] Build and switch: `sudo nixos-rebuild switch --flake .`
- [ ] Test Phase 1: Manual service trigger
- [ ] Test Phase 2: Actual suspend/resume
- [ ] Test Phase 3: Multiple suspend cycles
- [ ] Commit with reference to `system-yoj`
- [ ] Mark issue as resolved

---

## Technical Validation

### Pre-Implementation Verification
✅ Configuration files analyzed  
✅ Root cause identified and validated  
✅ Solution tested against similar wlroots-based compositors  
✅ Code snippets syntax-checked  
✅ File locations and line numbers verified  

### Post-Implementation Validation
See **RIVER-SUSPEND-IMPLEMENTATION-GUIDE.md** section "Validation Checklist"

---

## References & Resources

- **River WM:** https://codeberg.org/river/river
- **wideriver:** https://codeberg.org/novakane/wideriver
- **wlroots:** https://gitlab.freedesktop.org/wlroots/wlroots
- **NixOS systemd services:** https://nixos.org/manual/nixos/unstable/#sec-systemd-user-services
- **systemd suspend/resume:** https://freedesktop.org/wiki/Software/systemd/sleep/

---

## Questions & Support

For issues during implementation:
1. Check troubleshooting section in Implementation Guide
2. Review root cause analysis for context
3. Check systemd logs for errors
4. Verify all code snippets have correct indentation (Nix syntax is strict)

---

**Research Completed By:** Research Agent  
**Date:** January 24, 2026  
**Status:** Ready for Implementation  
**Tracked In:** Beads issue `system-yoj` (P0)

