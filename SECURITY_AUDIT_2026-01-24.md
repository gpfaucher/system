# 🔒 NixOS Security Audit Report
**System**: `/home/gabriel/projects/system` - Laptop Configuration  
**Date**: 2026-01-24  
**Auditor**: Claude Code (SECURITY Agent)  
**Overall Score**: **6.5/10**

---

## Executive Summary

This NixOS configuration has a **solid security foundation** with good practices like Wayland, rootless Docker, and firewall enabled. However, there are **critical issues requiring immediate attention**:

### 🚨 Critical Finding
- **Hardcoded authentication token** in version control (modules/home/default.nix)
- Tabby AI token `auth_872164f40d10473e861c75db73842900` exposed in git history
- **Requires immediate remediation**: token rotation, secrets management implementation

### ⚠️ High Priority Issues
- No kernel hardening sysctls configured
- Firewall allows 11 development ports permanently open
- Sudo configuration lacks hardening
- No Secure Boot or boot protection beyond editor disable
- Rootless Docker not fully isolated

### 📊 Security Posture Breakdown
| Category | Score | Status |
|----------|-------|--------|
| Basic Security | 7/10 | ✅ Good |
| Access Control | 5/10 | ⚠️ Needs Work |
| Secrets Management | 2/10 | ❌ Critical |
| Kernel Security | 4/10 | ⚠️ Needs Work |
| Service Isolation | 7/10 | ✅ Good |
| Monitoring | 3/10 | ⚠️ Needs Work |
| Boot Security | 6/10 | ⚠️ Needs Work |
| Update Management | 5/10 | ⚠️ Needs Work |

---

## Critical Vulnerabilities

### CRIT-001: Hardcoded Authentication Token (CWE-798)
**Severity**: CRITICAL  
**File**: `modules/home/default.nix:111`  
**Token**: `auth_872164f40d10473e861c75db73842900`

**Risk**: Anyone with repository access can authenticate to Tabby AI server

**Immediate Actions**:
1. Rotate token in Tabby web UI
2. Remove token from configuration
3. Implement sops-nix or agenix for secrets management
4. Scrub git history: `git filter-repo --path modules/home/default.nix --invert-paths`

**Beads Issue**: `system-cla` (P0)

---

## High Severity Issues

### HIGH-001: No Kernel Hardening
**File**: Missing configuration  
**Impact**: Easier kernel exploitation, networking attacks, privilege escalation

**Fix**: Add to configuration:
```nix
boot.kernel.sysctl = {
  "kernel.kptr_restrict" = 2;
  "kernel.unprivileged_bpf_disabled" = 1;
  "kernel.yama.ptrace_scope" = 2;
  "net.ipv4.tcp_syncookies" = 1;
  "fs.protected_hardlinks" = 1;
  # ... see full list in audit report
};
```
**Beads Issue**: `system-aye` (P1)

### HIGH-002: Excessive Firewall Exposure
**File**: `modules/system/networking.nix:11-22`  
**Issue**: 11 TCP ports permanently open (22,80,443,3000,4000,5000,5173,8000,8080,8888)

**Fix**: Close all ports by default
```nix
networking.firewall.allowedTCPPorts = [ ];
# Use temporary port opening or systemd socket activation
```
**Beads Issue**: `system-4o8` (P1)

### HIGH-003: Weak Sudo Configuration
**File**: `hosts/laptop/default.nix:69`  
**Issue**: User in wheel group has unrestricted sudo access

**Fix**: Add hardening configuration
```nix
security.sudo = {
  enable = true;
  execWheelOnly = true;
  wheelNeedsPassword = true;
  extraConfig = ''
    Defaults timestamp_timeout=15
    Defaults passwd_tries=3
    Defaults logfile=/var/log/sudo.log
    Defaults use_pty
  '';
};
```
**Beads Issue**: `system-cmx` (P1)

### HIGH-004: No Boot Security
**Issue**: No Secure Boot, no TPM usage, no boot encryption verification

**Recommendation**: Investigate Lanzaboote for Secure Boot support

### HIGH-005: Docker Not Fully Isolated
**Issue**: Rootless docker enabled (good!) but missing additional sandboxing

**Recommendation**: Consider switching to Podman (daemonless, more secure)

### HIGH-006: No AppArmor/SELinux
**Issue**: Applications run with full user permissions, no MAC confinement

**Fix**: Enable AppArmor
```nix
security.apparmor = {
  enable = true;
  packages = with pkgs; [ apparmor-profiles ];
};
```
**Beads Issue**: `system-178` (P2)

---

## Medium Severity Issues

- **MED-001**: No audit logging (auditd)
- **MED-002**: Systemd services missing hardening (tabby, kanshi, river-resume-hook)
- **MED-003**: No PAM password complexity requirements
- **MED-004**: Firefox Visibility API disabled globally (breaks web standards)
- **MED-005**: No automatic security updates (using nixos-unstable)
- **MED-006**: Polkit not hardened
- **MED-007**: No Flatpak/Bubblewrap application sandboxing

---

## Security Strengths ✅

1. **Bootloader Editor Disabled** - Prevents boot parameter tampering
2. **Rootless Docker** - Reduces container escape risk
3. **Firewall Enabled** - Basic network protection
4. **Wayland Over X11** - Better isolation than X11
5. **Systemd Hardening on bluetooth-monitor** - Good sandboxing example
6. **Zram Swap** - Prevents secrets in unencrypted swap
7. **Boot Partition Permissions** - Proper fmask=0077
8. **Verified Binary Caches** - Using trusted public keys

---

## Remediation Roadmap

### Phase 1: IMMEDIATE (Today)
- [ ] `system-cla` - Rotate and remove hardcoded Tabby token
- [ ] Implement sops-nix or agenix for secrets

### Phase 2: URGENT (This Week)
- [ ] `system-aye` - Add kernel hardening sysctls
- [ ] `system-cmx` - Harden sudo configuration  
- [ ] `system-4o8` - Lock down firewall
- [ ] `system-394` - Add systemd service hardening

### Phase 3: IMPORTANT (This Month)
- [ ] `system-1bc` - Create modules/system/hardening.nix
- [ ] `system-178` - Enable AppArmor
- [ ] Enable audit logging
- [ ] Configure PAM password quality
- [ ] Harden Polkit
- [ ] Fix Firefox configuration

### Phase 4: ENHANCEMENT (Nice to Have)
- [ ] Investigate Secure Boot
- [ ] Add TPM2 support
- [ ] Enable USBGuard
- [ ] Add AIDE file integrity monitoring
- [ ] Implement Flatpak sandboxing

---

## Recommended Hardening Module

Create `modules/system/hardening.nix` with:
- Kernel sysctls (network, kernel, filesystem hardening)
- Kernel module blacklist (rare/vulnerable modules)
- Firewall hardening (no open ports, reject packets)
- Sudo hardening (timeout, logging, pty)
- AppArmor enablement
- Audit logging
- PAM password quality
- Polkit restrictions
- Coredump restrictions

**Beads Issue**: `system-1bc` (P1)

---

## Compliance & Standards

This audit follows:
- **CIS Benchmark** principles
- **NIST Cybersecurity Framework** guidance
- **NixOS Security Best Practices**
- **Defense in Depth** methodology

---

## Next Steps

1. **Immediate**: Fix `system-cla` (hardcoded token)
2. **Review**: Prioritize P1 issues based on your threat model
3. **Implement**: Create hardening.nix module
4. **Monitor**: Set up audit logging for ongoing security
5. **Maintain**: Subscribe to NixOS security announcements

---

## Beads Issues Created

Run `bd ready --label security --pretty` to see all security issues.

**Critical (P0)**:
- `system-cla` - Remove hardcoded Tabby token

**High Priority (P1)**:
- `system-1bc` - Create hardening.nix module
- `system-aye` - Kernel hardening sysctls
- `system-4o8` - Firewall lockdown
- `system-cmx` - Sudo hardening

**Medium Priority (P2)**:
- `system-178` - Enable AppArmor
- `system-394` - Systemd service hardening

---

**End of Security Audit Report**  
For questions or remediation assistance, reference this document and the associated Beads issues.
