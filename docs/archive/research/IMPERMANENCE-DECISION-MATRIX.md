# Impermanence Implementation Decision Matrix

## Side-by-Side Comparison: Current vs Impermanent

### System State Management

```
Current Setup (persistent /):
  - Everything persists across boots
  - /var grows over time (logs, caches)
  - Old configs accumulate
  - Any crash can corrupt /var
  - Hard to know what's critical vs ephemeral

Impermanent Setup (tmpfs / + /persist):
  - Clean /var on every boot
  - Only explicit state persists
  - Old configs cleaned automatically
  - tmpfs can't be corrupted
  - Clear audit trail of what's persistent
```

### Boot Performance

```
Current Setup:
  ├─ Journal replay: ~500ms-2s (depends on log size)
  ├─ /var cleanup: ~100-500ms
  ├─ /var/lock recreation: ~100ms
  └─ Total overhead: 1-3 seconds

Impermanent Setup:
  ├─ tmpfs mount: ~10ms
  ├─ Bind mount /persist: ~50ms
  ├─ No journal replay needed: saves 500ms-2s
  ├─ No /var cleanup: saves 100-500ms
  └─ Net improvement: +500ms-2.5s faster boot
```

### Storage Requirements

**Current System:**

```
/              = Btrfs @ subvolume
  ├─ /nix      = 55GB (packages)
  ├─ /var      = 185MB (mostly logs)
  ├─ /etc      = ~200KB (configs)
  ├─ /usr      = symlinks to /nix
  ├─ /lib      = symlinks to /nix
  └─ /root     = ~1KB

Total disk used: 55GB
Btrfs snapshots possible: Yes ✓
Subvolume separation: Good (@home separate) ✓
```

**With Impermanence:**

```
tmpfs / (2GB) - ephemeral
├─ Fresh on every boot
├─ No accumulation
└─ Automatic cleanup

/persist (Btrfs) - persistent
├─ /var/lib/    = ~30MB
├─ /etc/        = ~100KB
└─ home state   = ~3-5GB
Total: ~3-5GB

/nix (Btrfs) - persistent
├─ /nix/store   = 55GB
└─ As before

Total disk used: ~58-60GB (same)
Btrfs snapshots: Can snapshot /persist ✓
Subvolume separation: Great (clear layering) ✓✓
Rebuild complexity: +1 subvolume (@persist)
```

### Application State Handling

#### Critical Applications

**NetworkManager:**

```
Current:
  └─ /var/lib/NetworkManager (persists, but can grow with history)

Impermanent:
  └─ /persist/var/lib/NetworkManager (explicit, bounded)
  ✓ Ensures WiFi credentials persist
  ✓ VPN configs stay available
  ✓ Old connection history cleaned at each reboot
```

**Docker:**

```
Current:
  └─ /var/lib/docker (grows unbounded with images/containers)

Impermanent:
  └─ /persist/var/lib/docker (explicit, still persists)
  ✓ Container state preserved
  ✓ Images and volumes available
  ✓ Old tmp files cleaned on reboot
  ✓ Must mount before docker.service starts
```

**Systemd Journal:**

```
Current:
  └─ /var/log/journal (grows to journald.MaxDiskSize)

Impermanent:
  Option A) /persist/var/log/journal (keep last N days)
  Option B) /run/log/journal (tmpfs, lost on reboot)

  Recommendation: Option A with 7-day retention
  ✓ Can debug boot issues with logs
  ✓ Bound by MaxDiskSize = 1GB
  ✓ Old logs cleaned automatically
```

**SSH/AWS Credentials:**

```
Current:
  ├─ ~/.ssh/ (in /home subvolume, persists) ✓
  └─ ~/.aws/ (in /home subvolume, persists) ✓

Impermanent:
  ├─ /persist/home/gabriel/.ssh/ (MUST bind) ✓
  └─ /persist/home/gabriel/.aws/ (MUST bind) ✓

  ⚠️ CRITICAL: These MUST be in /persist or backed up
  ✓ Consider agenix/sops-nix for encryption
```

---

## Recommendation Decision Tree

```
Does your system fit this profile?
├─ Linux distro: YES ✓
├─ NixOS: YES ✓
├─ Btrfs filesystem: YES ✓
├─ Single user or simple multi-user: YES ✓
├─ Run Docker/containers: YES ✓
├─ Have WiFi/VPN to preserve: YES ✓
├─ Want cleaner system state: YES ✓
├─ Willing to test carefully: YES ✓
└─ Can backup /persist: YES ✓

→ IMPLEMENT IMPERMANENCE ✓✓✓

Questions that might delay implementation:
├─ Need persistent syslog compliance? → Keep journald persistent
├─ Manually edit /etc often? → Document as NixOS config instead
├─ Complex stateful services? → Identify explicit persistence points
├─ Backup concerns? → Design backup strategy before implementation
└─ Unfamiliar with Btrfs? → Learn subvolume management first

Questions that would argue against it:
├─ Need /var/log across reboots for compliance? → Not suitable
├─ Have many ad-hoc /etc modifications? → Not suitable
├─ Complex multisystem shared state? → Not suitable
├─ Can't afford 4 hours implementation time? → Delay, not suitable
└─ Zero tolerance for migration risk? → Not suitable

Current assessment: ALL criteria met → RECOMMENDED
```

---

## Risk Assessment

### Implementation Risks (Mitigated)

| Risk                            | Likelihood | Impact   | Mitigation                                      |
| ------------------------------- | ---------- | -------- | ----------------------------------------------- |
| SSH keys lost                   | Low        | Critical | Backup /persist, use agenix                     |
| Network won't work after reboot | Low        | High     | Pre-copy NM config, test                        |
| Docker data lost                | Low        | High     | Verify /persist mounted before docker.service   |
| System won't boot               | Low        | Critical | Keep @-backup, test each step                   |
| /etc/machine-id issues          | Medium     | High     | Pre-create with correct value                   |
| App state lost unexpectedly     | Low        | Medium   | Document what needs /persist                    |
| /persist fills up               | Low        | Medium   | Monitor with du, set MaxDiskSize                |
| Backup complexity forgotten     | Medium     | High     | Document backup procedure before implementation |

### Operational Risks (Ongoing)

| Risk                                  | Likelihood | Impact | Mitigation                                       |
| ------------------------------------- | ---------- | ------ | ------------------------------------------------ |
| Logs lost on crash                    | Medium     | Low    | Use systemd journal, keep persistent             |
| Old configs lingering                 | Low        | Low    | Automatic with ephemeral root                    |
| Permissions issues on /persist        | Low        | Medium | Careful chown during setup                       |
| Services starting before mounts ready | Low        | High   | Use systemd.tmpfiles.rules with correct ordering |

---

## Timeline & Effort Breakdown

### Phase 1: Preparation (1 hour)

```
- Document current /var/lib contents
- Create /persist subvolume
- Pre-create directory structure
- Take filesystem backup
```

### Phase 2: State Migration (30 minutes)

```
- Copy /var/lib/{systemd,docker,nm,bluetooth,nixos}
- Copy user state (~3GB of .ssh, .aws, .config, .local)
- Copy system identifiers (/etc/machine-id, /etc/adjtime)
- Verify all permissions correct
```

### Phase 3: NixOS Configuration (45 minutes)

```
- Add impermanence flake input
- Create impermanence.nix system module
- Create persistence.nix home module
- Build and test configuration
```

### Phase 4: Testing & Validation (1 hour)

```
- Boot with new configuration
- Verify mounts in place
- Test network (NM config)
- Test Bluetooth (pairing)
- Test Docker (images/containers)
- Test SSH/AWS (credentials available)
- Test reboot clears /tmp
- Create test file, reboot, verify ephemeral
```

### Phase 5: Documentation & Cleanup (30 minutes)

```
- Document any app-specific quirks discovered
- Create backup/restore procedure
- Delete @-backup subvolume after 1 week
- Set up /persist disk usage monitoring
- Create RUNBOOK for future modifications
```

**Total Time: 3.75 hours (round to 4 hours with buffer)**

---

## Success Criteria

✅ System boots normally with tmpfs /
✅ Network connects (NM credentials loaded)
✅ Bluetooth shows paired devices
✅ Docker containers/images present
✅ SSH keys accessible
✅ Files in /tmp disappear after reboot
✅ Log directory (journald) persists
✅ System is more stable than before
✅ Boot time improved or unchanged
✅ /persist backed up with system

---

## Rollback Plan

If impermanence causes issues:

```bash
# Immediate rollback (within 1 week of change)
# 1. Boot from recovery (keep @-backup)
# 2. Restore from snapshot:
sudo btrfs subvolume delete /
sudo btrfs subvolume snapshot @-backup @

# 2. Or restore old configuration:
# Revert flake.nix/hardware.nix changes
# Switch back to old generation:
sudo nixos-rebuild switch --flake .#laptop --rollback

# After investigation, can try again with fixes
```

---

## Post-Implementation Monitoring

### Daily

- Check network connectivity works
- Verify Docker containers start
- No unexpected boot failures

### Weekly

- Check /persist disk usage: `du -sh /persist`
- Review journald size: `du -sh /var/log/journal`
- Look for any persistence-related errors in logs

### Monthly

- Verify backup strategy still works
- Check if any new apps need /persist entries
- Review any permission issues
- Update documentation with lessons learned

---

## Comparison to Alternatives

### Option A: No Change (Current Persistent /)

```
Pros:  Simple, everything works as-is
Cons:  /var grows, crashes can corrupt, messy state

Score: 3/10 for professional dev system
```

### Option B: Impermanence (Recommended)

```
Pros:  Clean state, faster boot, alignment with NixOS,
       clear persistence model, reduces disk issues
Cons:  Requires 4 hours setup, needs careful testing,
       must backup /persist

Score: 9/10 for professional dev system
```

### Option C: Immutable OS (Like ostree)

```
Pros:  Atomic updates, strong protection against config drift
Cons:  Complete OS redesign, not NixOS, high complexity

Score: Not applicable (different architecture)
```

### Option D: Frequent Snapshots + LVM

```
Pros:  Protection against corruption
Cons:  Doesn't reduce state growth, slower boot,
       complex recovery, not stateless

Score: 5/10 for professional dev system
```

---

## Final Recommendation

**Status: ✅ STRONGLY RECOMMENDED FOR THIS SYSTEM**

**Rationale:**

1. System is naturally suited (Btrfs, NixOS, single-user)
2. Benefits are substantial (cleaner state, faster boot, clearer mental model)
3. Risks are well-understood and mitigatable
4. Implementation effort is reasonable (4 hours)
5. Aligns with modern NixOS best practices
6. Professional development workflow benefits

**Next Step:** Proceed with Phase 1 after securing a full filesystem backup.
