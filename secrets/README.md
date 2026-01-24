# Agenix Secrets

This directory contains encrypted secrets managed by [agenix](https://github.com/ryantm/agenix).

## Overview

Secrets are encrypted using age with SSH public keys. Only users/systems with the corresponding private keys can decrypt them.

## Current Secrets

- `tabby-token.age` - Authentication token for Tabby AI code completion server
  - Decrypted to: `/run/agenix/tabby-token`
  - Owner: gabriel
  - Permissions: 0400 (read-only for owner)

## Configuration Files

- `secrets.nix` - Defines which SSH public keys can decrypt which secrets
- `default.nix` - Configures how secrets are decrypted and where they're placed
- `*.age` - Encrypted secret files (safe to commit to git)

## Usage

### Viewing/Editing Secrets

To view or edit an encrypted secret:

```bash
# Using agenix (if installed)
agenix -e tabby-token.age

# Or using age directly
age -d -i ~/.ssh/id_ed25519 tabby-token.age
```

### Creating New Secrets

1. Add the secret definition to `secrets.nix`:
```nix
"new-secret.age".publicKeys = [ gabriel ];
```

2. Encrypt the secret:
```bash
echo -n "secret-value" | age -r "$(cat ~/.ssh/id_ed25519.pub)" > new-secret.age
```

3. Configure decryption in `default.nix`:
```nix
age.secrets.new-secret = {
  file = ./new-secret.age;
  owner = "gabriel";
  group = "users";
  mode = "0400";
};
```

4. Apply changes:
```bash
sudo nixos-rebuild switch --flake .#laptop
```

### Re-encrypting Secrets (e.g., after key rotation)

```bash
# Decrypt with old key
age -d -i ~/.ssh/id_ed25519.old tabby-token.age > /tmp/secret

# Re-encrypt with new key
cat /tmp/secret | age -r "$(cat ~/.ssh/id_ed25519.pub)" > tabby-token.age

# Securely delete temporary file
shred -u /tmp/secret
```

## Security Notes

- Encrypted `.age` files are **safe to commit to git**
- Private SSH keys (`~/.ssh/id_ed25519`) must be protected
- Decrypted secrets in `/run/agenix/` are only accessible to specified owners
- Always use `echo -n` to avoid trailing newlines in secrets
- Never commit unencrypted secrets or private keys

## How It Works

1. During NixOS build, agenix reads `secrets.nix` and `default.nix`
2. At boot/rebuild, agenix decrypts secrets using the system's SSH host key or user's SSH key
3. Decrypted secrets are placed in `/run/agenix/` with specified permissions
4. Applications read secrets from `/run/agenix/` at runtime

For the Tabby configuration, `modules/home/default.nix` uses a home-manager activation script that reads the decrypted token from `/run/agenix/tabby-token` and generates the config file.
