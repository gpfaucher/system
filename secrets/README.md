# Agenix Secrets

This directory contains encrypted secrets managed by [agenix](https://github.com/ryantm/agenix).

## Overview

Secrets are encrypted using age with SSH public keys. Only users/systems with the corresponding private keys can decrypt them.

## Current Secrets

- `aws-credentials.age` - AWS credentials for CLI access
  - Decrypted to: `/home/gabriel/.aws/credentials`
  - Owner: gabriel
  - Permissions: 0400 (read-only for owner)

## Configuration Files

- `secrets.nix` - Defines which SSH public keys can decrypt which secrets
- `default.nix` - Configures how secrets are decrypted and where they're placed
- `*.age` - Encrypted secret files (safe to commit to git)

## Usage

### Viewing/Editing Secrets

```bash
# Using agenix (if installed)
agenix -e aws-credentials.age

# Or using age directly
age -d -i ~/.ssh/id_ed25519 aws-credentials.age
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

## Security Notes

- Encrypted `.age` files are **safe to commit to git**
- Private SSH keys (`~/.ssh/id_ed25519`) must be protected
- Decrypted secrets in `/run/agenix/` are only accessible to specified owners
- Always use `echo -n` to avoid trailing newlines in secrets
- Never commit unencrypted secrets or private keys
