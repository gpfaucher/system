{
  config,
  lib,
  pkgs,
  ...
}:

{
  # ============================================================================
  # SECURITY HARDENING MODULE
  # ============================================================================
  # This module implements comprehensive security hardening for NixOS systems.
  # It covers kernel parameters, sudo configuration, AppArmor, audit logging,
  # and PAM settings following security best practices.
  # ============================================================================

  # ----------------------------------------------------------------------------
  # KERNEL HARDENING
  # ----------------------------------------------------------------------------
  # Kernel parameters to restrict access to sensitive information and harden
  # the system against various attack vectors.

  boot.kernel.sysctl = {
    # Kernel pointer protection - hide kernel pointers from unprivileged users
    # 0 = no restriction, 1 = hide from unprivileged, 2 = always hide
    "kernel.kptr_restrict" = 2;

    # Restrict dmesg access to root only (prevent information disclosure)
    "kernel.dmesg_restrict" = 1;

    # Disable unprivileged BPF to prevent potential privilege escalation
    "kernel.unprivileged_bpf_disabled" = 1;

    # Harden BPF JIT compiler against spray attacks
    # 0 = disabled, 1 = for unprivileged, 2 = for all users
    "net.core.bpf_jit_harden" = 2;

    # Restrict ptrace to processes with CAP_SYS_PTRACE or parent-child relationship
    # 0 = classic ptrace, 1 = restricted, 2 = admin only, 3 = no attach
    "kernel.yama.ptrace_scope" = 1;

    # Restrict perf_event_open syscall to reduce attack surface
    # -1 = no restriction, 0 = some restriction, 1 = restricted, 2 = kernel only, 3 = no access
    "kernel.perf_event_paranoid" = 3;

    # Disable kexec to prevent kernel replacement
    "kernel.kexec_load_disabled" = 1;

    # ----------------------------------------------------------------------------
    # NETWORK HARDENING
    # ----------------------------------------------------------------------------

    # Enable reverse path filtering (helps prevent IP spoofing)
    # 0 = disabled, 1 = strict mode, 2 = loose mode
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    # Disable ICMP redirect acceptance (prevents MITM attacks)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;

    # Disable secure ICMP redirects (even from gateways)
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;

    # Disable IPv6 router advertisements and redirects
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
  };

  # ----------------------------------------------------------------------------
  # SUDO HARDENING
  # ----------------------------------------------------------------------------
  # Enhanced sudo security configuration to reduce privilege escalation risks.

  security.sudo = {
    # Only allow sudo execution for users in the wheel group
    execWheelOnly = true;

    # Additional sudo hardening options
    extraConfig = ''
      # Always show the sudo lecture (security reminder)
      Defaults lecture = always

      # Set password timeout to 1 minute (fail fast on slow password entry)
      Defaults passwd_timeout = 1

      # Require password re-entry after 15 minutes of inactivity
      Defaults timestamp_timeout = 15

      # Reset environment variables to prevent privilege escalation via env vars
      Defaults env_reset

      # Send mail notification on bad password attempts (requires mail setup)
      Defaults mail_badpass
    '';
  };

  # ----------------------------------------------------------------------------
  # APPARMOR MANDATORY ACCESS CONTROL
  # ----------------------------------------------------------------------------
  # AppArmor provides mandatory access control to confine programs.

  security.apparmor = {
    enable = true;

    # When set to true, kills processes that should be confined but aren't
    # Start with false and monitor logs before enabling
    killUnconfinedConfinables = false; # TODO: Set to true after testing profiles
  };

  # ----------------------------------------------------------------------------
  # AUDIT LOGGING
  # ----------------------------------------------------------------------------
  # Comprehensive audit logging to track security-relevant events.

  security.auditd.enable = true;
  security.audit = {
    enable = true;

    # Audit rules to track process execution
    # This logs all execve system calls (program executions) on 64-bit systems
    rules = [
      "-a exit,always -F arch=b64 -S execve"
    ];
  };

  # ----------------------------------------------------------------------------
  # PAM HARDENING AND LIMITS
  # ----------------------------------------------------------------------------
  # Configure PAM (Pluggable Authentication Modules) resource limits.

  security.pam.loginLimits = [
    # File descriptor limits (prevents DoS via file descriptor exhaustion)
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];

  # ----------------------------------------------------------------------------
  # FIREWALL CONFIGURATION (Reference)
  # ----------------------------------------------------------------------------
  # Firewall is configured in networking.nix with the following open ports:
  #
  # TCP Ports:
  #   22    - SSH (remote access)
  #   80    - HTTP (web development)
  #   443   - HTTPS (secure web development)
  #   3000  - Node.js/React development server
  #   4000  - Phoenix/Elixir development server
  #   5000  - Flask/generic development server
  #   5173  - Vite development server
  #   8000  - Django/Python development server
  #   8080  - Alternative HTTP / Tabby AI server
  #   8888  - Jupyter notebook server
  #
  # Note: Consider restricting development ports to localhost-only in production
  # or on untrusted networks by using iptables rules or NetworkManager zones.
  # ----------------------------------------------------------------------------
}
