# Comprehensive NixOS Secrets Management Analysis & Implementation Guide

**Analysis Date**: January 24, 2026  
**System**: `/home/gabriel/projects/system` (Professional NixOS Configuration)  
**Research Scope**: Current state, agenix vs sops-nix comparison, implementation patterns

---

## EXECUTIVE SUMMARY

### Current State: ⚠️ SECURITY ISSUE FOUND

**CRITICAL FINDING**: Hardcoded API token in version control
- **Location**: `/home/gabriel/projects/system/modules/home/default.nix:111`
- **Token**: `auth_872164f40d10473e861c75db73842900` (Tabby agent)
- **Risk Level**: HIGH - Exposed in git history, accessible to anyone with repo access
- **Status**: NO secrets management infrastructure currently in place

### Key Findings
1. **No existing secrets management system** (agenix/sops-nix not in use)
2. **Hardcoded tokens in Nix modules** (direct exposure)
3. **Multiple secret categories requiring protection**:
   - API tokens (Tabby agent, GitHub, cloud providers)
   - SSH keys
   - Wireless network passwords
   - Service credentials
   - Database passwords
   - VPN configurations

### Recommendation
**IMMEDIATE PRIORITY**: Implement agenix for this system
- Reason: Simpler setup, SSH key infrastructure already in place
- Timeline: Can be implemented in 2-3 hours
- Zero additional dependencies required (uses existing SSH keys)

---

## PART 1: CURRENT STATE ANALYSIS

### 1.1 Hardcoded Secrets Found

#### Tabby Agent Token (CRITICAL)
```nix
# File: modules/home/default.nix:108-112
home.file.".tabby-client/agent/config.toml".text = ''
  [server]
  endpoint = "http://localhost:8080"
  token = "auth_872164f40d10473e861c75db73842900"
'';
```

**Issues**:
- Token committed to git
- World-readable in Nix store
- No expiration management
- Could provide unauthorized access to Tabby completion server

#### Other Potential Secrets (Not Yet Found, But Should Be Protected)
- SSH keys for GitHub/Git services
- API keys for cloud providers (AWS, GCP, Azure)
- Database connection strings
- Wireless network PSKs
- VPN credentials
- Service tokens

### 1.2 Network Configuration (Currently Safe)
```nix
# File: modules/system/networking.nix
# Uses NetworkManager for wireless
# No hardcoded WiFi passwords found
# GOOD: Handled separately via nmcli/NetworkManager
```

### 1.3 Git Configuration (Safe)
```nix
# File: modules/home/default.nix:47-56
programs.git = {
  enable = true;
  settings = {
    user.name = "Gabriel Faucher";
    user.email = "gpfaucher@gmail.com";  # Public email, safe
    init.defaultBranch = "main";
    pull.rebase = true;
    push.autoSetupRemote = true;
  };
};
```

### 1.4 Existing Infrastructure
**SSH Keys**: ✅ Present
```
~/.ssh/id_ed25519          # User SSH key
~/.ssh/id_ed25519.pub      # Public key
/etc/ssh/ssh_host_ed25519_key  # System host key
```

**flake.nix**: Already uses specialArgs (good for secrets module integration)
```nix
outputs = { self, nixpkgs, home-manager, nvf, stylix, ghostty, beads, ... }@inputs:
  ...
  specialArgs = { inherit inputs username self; };
```

---

## PART 2: AGENIX DEEP DIVE

### 2.1 How agenix Works

**Core Concept**: Encrypt secrets with public SSH keys, decrypt with private SSH keys during NixOS activation

**Workflow**:
```
User's Local Machine:
  1. agenix CLI + SSH key (~/.ssh/id_ed25519)
  2. Edit secret with: agenix -e my-secret.age
  3. File encrypted with PUBLIC keys from secrets.nix
  4. Commit .age file to git (safe - encrypted)

Target Machine (System Activation):
  1. Secret file copied to Nix store
  2. agenix module decrypts using HOST private SSH key
  3. Mounted at /run/agenix/<secret-name>
  4. Services reference config.age.secrets.<name>.path
```

**Key Files**:
- `secrets.nix` - Lists which keys can decrypt which secrets (NOT imported, git-safe)
- `*.age` - Encrypted secret files (safe in git, uses age format)
- Module: `agenix.nixosModules.default` (handles decryption)

### 2.2 Agenix Advantages

| Feature | Benefit |
|---------|---------|
| **SSH-based** | Uses existing infrastructure (no new key management) |
| **Simple** | ~300 lines of Nix code (easy to audit) |
| **Flake support** | Perfect fit for your flake.nix setup |
| **No GPG** | Avoids GPG complexity and reliability issues |
| **age format** | Modern, fast (Filippo Valsorda's cryptography library) |
| **Per-secret control** | Fine-grained ownership/permissions |
| **Home-manager** | Native support for user secrets |
| **Small footprint** | Single binary, minimal dependencies |
| **Ed25519 support** | Works perfectly with modern SSH keys |

### 2.3 Agenix Limitations

| Limitation | Impact | Workaround |
|-----------|--------|-----------|
| **No message auth** | Encrypted but not authenticated (unlike sops) | Accept risk or use sops |
| **Password-protected SSH keys** | age can't use ssh-agent | Use unencrypted SSH key |
| **No team key rotation** | Manual rekeying required | Plan rotation schedule |
| **Not post-quantum safe** | Harvest-now-decrypt-later risk | Rotate secrets periodically |
| **Evaluation-time secrets** | Can't use secrets during nix evaluation | Use runtime references only |

### 2.4 Agenix Module Reference

#### Basic Structure
```nix
# In your NixOS configuration
{
  imports = [ agenix.nixosModules.default ];
  
  age.secrets.my-secret = {
    file = ../secrets/my-secret.age;
    path = "/run/agenix/my-secret";           # default
    owner = "root";                            # default
    group = "root";                            # default
    mode = "0600";                             # default (owner-only)
  };
}
```

#### Usage in Configuration
```nix
# Bad (don't do this):
config.some-option = builtins.readFile config.age.secrets.my-secret.path;
# ^ Puts secret in Nix store (world-readable!)

# Good (do this):
services.my-service = {
  tokenFile = config.age.secrets.my-token.path;
  # ^ Service reads at runtime
};
```

### 2.5 Identity Paths (Key Discovery)

By default, agenix uses SSH host keys:
```nix
config.services.openssh.hostKeys
```

On NixOS, this is automatic. For home-manager:
```nix
age.identityPaths = [ "~/.ssh/id_ed25519" ];
```

---

## PART 3: SOPS-NIX COMPARISON

### 3.1 How sops-nix Works

**Architecture**: Mozilla's SOPS tool + Nix integration
- Secrets in `.sops.yaml`/`.json` format
- Stores ONE master encryption key
- Encrypts/decrypts via: age, GPG, AWS KMS, GCP KMS, Azure Vault, HashiCorp Vault
- Sops handles all encryption - more feature-rich

### 3.2 Side-by-Side Comparison

| Aspect | agenix | sops-nix |
|--------|---------|----------|
| **Setup Time** | 30 minutes | 1-2 hours |
| **Single Host** | ✅ Perfect | ✅ Works |
| **Team Collab** | Manual rekey | Master key sharing |
| **Cloud KMS** | ❌ No | ✅ Yes (AWS/GCP/Azure) |
| **Encryption** | age (public-key) | Multiple backends |
| **Message Auth** | ❌ No | ✅ Yes (MAC) |
| **YAML Support** | ❌ Simple text | ✅ Full YAML |
| **Code Audit** | 📖 Easy (small) | 📖 Moderate (larger) |
| **Dependencies** | age, openssh | sops, openssl, etc |
| **Learning Curve** | Gentle | Moderate |

### 3.3 When to Use Each

**Use agenix if**:
- ✅ Single machine or small team
- ✅ SSH keys already managed
- ✅ No cloud KMS needed
- ✅ Want minimal dependencies
- ✅ Prefer simple, auditable code

**Use sops-nix if**:
- ✅ Large team with shared master key
- ✅ Using AWS/GCP/Azure KMS
- ✅ Need authenticated encryption (MAC)
- ✅ Complex YAML/JSON secret structures
- ✅ Want SOPS ecosystem compatibility

---

## PART 4: NIXOS SECRETS BEST PRACTICES

### 4.1 Categories of Secrets in NixOS

#### 1. **SSH Keys**
```nix
# CORRECT: Reference path, don't embed
services.openssh = {
  enable = true;
  hostKeys = [
    { type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }
  ];
};

# In secrets:
age.secrets.github-key.file = ../secrets/github-deploy-key.age;

# In config:
users.users.git.openssh.authorizedKeys.keyFiles = 
  [ config.age.secrets.github-key.path ];
```

#### 2. **API Tokens & Service Credentials**
```nix
# CORRECT: Via environment file or runtime reference
systemd.services.my-service = {
  serviceConfig = {
    EnvironmentFiles = [ config.age.secrets.api-token.path ];
    # Or: ExecStart = "${pkgs.my-service}/bin/run --token-file=${...path}"
  };
};

age.secrets.api-token = {
  file = ../secrets/api-token.age;
  mode = "0400";
  owner = "my-service";
};
```

#### 3. **Database Passwords**
```nix
# CORRECT: Store in separate secret file
services.postgresql = {
  enable = true;
  ensureUsers = [
    {
      name = "app";
      ensureDBOwnership = true;
    }
  ];
  initialScript = "${config.age.secrets.db-password.path}";
};

age.secrets.db-password = {
  file = ../secrets/db-password.age;
  owner = "postgres";
  mode = "0400";
};
```

#### 4. **Wireless Network Passwords**
```nix
# GOOD: NetworkManager handles separately (not in Nix)
networking.networkmanager.enable = true;

# Passwords stored in:
# ~/.local/share/NetworkManager/system-connections/
# (User manages via nmcli, systemd-networkd, or nm-applet)

# IF needed in Nix config:
age.secrets.wifi-psk = {
  file = ../secrets/wifi-psk.age;
};
# Then use in networking.wireless.networks
```

#### 5. **VPN Configurations**
```nix
# CORRECT: Secret reference for credentials
services.openvpn.servers.myvpn = {
  config = ''
    # ... OpenVPN config ...
    auth-user-pass ${config.age.secrets.vpn-creds.path}
  '';
};

age.secrets.vpn-creds = {
  file = ../secrets/vpn-credentials.age;
  mode = "0600";
};
```

#### 6. **TLS/SSL Certificates & Keys**
```nix
# CORRECT: Key as secret, cert can be public
security.acme.certs.example.com = {
  email = "admin@example.com";
  # Key auto-managed by Let's Encrypt
};

# For self-signed or private CAs:
age.secrets.tls-key = {
  file = ../secrets/tls-key.age;
  mode = "0400";
  owner = "nginx";
};

services.nginx.virtualHosts."example.com" = {
  sslCertificate = "/etc/ssl/certs/example.crt";
  sslCertificateKey = config.age.secrets.tls-key.path;
};
```

### 4.2 Secret Organization Strategy

#### Directory Structure
```
secrets/
├── secrets.nix              # Public key configuration (COMMIT THIS)
├── common/
│   ├── api-token.age       # Shared across all hosts
│   └── db-password.age
├── laptop/
│   ├── wifi-psk.age        # Laptop-only secrets
│   ├── github-key.age
│   └── tabby-token.age
└── server/
    ├── database-backup.age
    └── ssl-key.age
```

#### secrets.nix Example
```nix
let
  # Personal SSH key (for editing)
  gabriel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiuc...";
  
  # System host keys (for decryption)
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzxQgondgEY...";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1c...";
  
  all = [ gabriel laptop server ];
in
{
  # Shared secrets (all hosts can decrypt)
  "common/api-token.age".publicKeys = all;
  "common/db-password.age".publicKeys = all;
  
  # Laptop-only secrets
  "laptop/wifi-psk.age".publicKeys = [ gabriel laptop ];
  "laptop/github-key.age".publicKeys = [ gabriel laptop ];
  "laptop/tabby-token.age".publicKeys = [ gabriel laptop ];
  
  # Server-only secrets
  "server/database-backup.age".publicKeys = [ gabriel server ];
  "server/ssl-key.age".publicKeys = [ gabriel server ];
}
```

### 4.3 Workflow: Create & Edit Secrets

#### First Time Setup
```bash
# 1. Create secrets directory
mkdir -p ~/projects/system/secrets

# 2. Get system's SSH public key
ssh-keyscan localhost
# or for remote:
ssh-keyscan example.com

# 3. Create secrets.nix with public keys
cat > ~/projects/system/secrets/secrets.nix << 'EOF'
let
  gabriel = builtins.readFile ~/.ssh/id_ed25519.pub;
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..."; # from ssh-keyscan
in
{
  "tabby-token.age".publicKeys = [ gabriel laptop ];
  "github-key.age".publicKeys = [ gabriel laptop ];
}
