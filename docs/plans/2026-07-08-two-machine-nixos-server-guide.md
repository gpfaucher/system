# Two-Machine NixOS Server Guide

Date: 2026-07-08

## Target

This repository should move toward a simple two-machine setup:

- MacBook: daily driver, managed by nix-darwin and Home Manager.
- Old workstation: wiped/rebuilt as a headless NixOS server.

The old NixOS workstation role should disappear. There should be no long-term
desktop Linux workstation in this flake unless that machine comes back later as
a deliberate new host.

The learning goal matters as much as the end state. The work should be done in
small phases where each phase teaches one Nix or Kubernetes idea clearly.

## Current State

The flake should expose only the two intended machines:

- `darwinConfigurations.macbook`
- `nixosConfigurations.server`

The old Linux desktop host folders have been removed:

- `hosts/laptop`
- `hosts/workstation`

The server host now lives at `hosts/server`. It starts from a placeholder
hardware file that must be regenerated on the actual machine before install.

The server role now lives under `modules/nixos`. It is intentionally headless:

- `modules/nixos/base`: Nix settings, user, SSH, network, hardening, maintenance.
- `modules/nixos/roles/server.nix`: small server package/profile layer.
- `modules/nixos/services/k3s.nix`: single-node Kubernetes.
- `modules/nixos/services/ingress.nix`: public HTTP/HTTPS ingress ports.
- `modules/nixos/services/backups.nix`: restic scaffolding.
- `secrets/default.nix`: old agenix-style secret config, not yet wired into the
  current flake.

The home layer should stay unified:

- `modules/home/default.nix` is the shared entrypoint.
- `modules/home/platforms/darwin.nix` contains Darwin-only user config.
- `modules/home/platforms/linux.nix` contains Linux-only user config.
- `modules/home/profiles/macbook.nix` contains MacBook user tooling.
- `modules/home/profiles/server-admin.nix` contains server admin tooling.

## End-State Shape

Aim for this structure:

```text
flake.nix

hosts/
  macbook/
    default.nix
  server/
    default.nix
    hardware.nix

modules/
  darwin/
    default.nix
    homebrew.nix
    system-defaults.nix

  nixos/
    base/
      default.nix
      nix.nix
      users.nix
      ssh.nix
      networking.nix
      maintenance.nix
      hardening.nix
    roles/
      server.nix
    services/
      k3s.nix
      ingress.nix
      backups.nix

  home/
    default.nix
    common/
      shell.nix
      git.nix
      ssh.nix
      tmux.nix
      nvim/
      terminal.nix
      devtools.nix
    platforms/
      darwin.nix
      linux.nix
    profiles/
      macbook.nix
      server-admin.nix
```

This is not a command to move everything at once. It is the destination map.

## Design Rules

Keep these rules in mind while restructuring:

1. Hosts should be thin.

   A host file should answer: what machine is this, what hardware does it have,
   and what roles does it run?

2. Modules should be reusable.

   A module should express one concern: SSH, k3s, backups, users,
   Homebrew, shell, Neovim, and so on.

3. Darwin and NixOS system modules should stay separate.

   nix-darwin and NixOS use different option namespaces. Trying to make one
   universal system module will create confusing conditionals.

4. Home Manager can be shared across platforms.

   Home Manager is where platform conditionals make sense:

   ```nix
   imports =
     commonImports
     ++ lib.optionals pkgs.stdenv.isDarwin [ ./platforms/darwin.nix ]
     ++ lib.optionals pkgs.stdenv.isLinux [ ./platforms/linux.nix ];
   ```

5. Server modules should be boring.

   No KDE. No Steam. No audio stack. No Flatpak. No VR. No Logitech. No desktop
   assumptions. A good server config is small, explicit, and easy to rebuild
   over SSH.

6. Kubernetes should not come first.

   First make the machine a reliable NixOS server. Then add k3s. Then expose
   services.

## Phase 1: Clean Up The Flake Shape

Goal: make the flake clearly describe the two intended machines.

Do not start by installing Kubernetes. First make the top-level outputs readable.

Conceptually, `flake.nix` should have helper functions:

```nix
let
  username = "gabrielfaucher";

  mkDarwinHost = name: system:
    darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit inputs username; };
      modules = [
        ./hosts/${name}
        home-manager.darwinModules.home-manager
        ./modules/darwin
      ];
    };

  mkNixosHost = name: system:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs username; };
      modules = [
        ./hosts/${name}
        home-manager.nixosModules.home-manager
      ];
    };
in
{
  darwinConfigurations.macbook = mkDarwinHost "macbook" "aarch64-darwin";
  nixosConfigurations.server = mkNixosHost "server" "x86_64-linux";
}
```

Treat this as a sketch, not a paste-ready final version. The exact imports
depend on how the modules are split in later phases.

What to learn here:

- Flake inputs are dependencies.
- Flake outputs are the build targets you can select.
- `darwin.lib.darwinSystem` builds macOS system configs.
- `nixpkgs.lib.nixosSystem` builds NixOS system configs.
- `specialArgs` passes shared values such as `inputs` and `username` into your
  modules.

Useful checks:

```bash
nix flake show
nix eval .#darwinConfigurations.macbook.system
nix eval .#nixosConfigurations.server.config.networking.hostName
```

Expected result:

- The Mac still evaluates.
- The future server target appears in `nix flake show`.
- It does not need to be fully deployable yet.

## Phase 2: Rename The Workstation Host To Server

Goal: stop thinking of the old workstation as a desktop machine.

Recommended approach:

1. Keep `hosts/server`.
2. Replace `hosts/server/hardware.nix` with the generated hardware config from
   the actual server.
3. Keep `hosts/server/default.nix` small and role-oriented.
4. Do not reintroduce `hosts/workstation` unless a Linux desktop machine comes
   back as a deliberate new host.

The new server host should look more like this:

```nix
{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/base
    ../../modules/nixos/roles/server.nix
    ../../modules/nixos/services/backups.nix
    ../../modules/nixos/services/ingress.nix
    ../../modules/nixos/services/k3s.nix
  ];

  networking.hostName = "server";

  system.stateVersion = "24.11";
}
```

Do not import these old workstation modules into the server:

- `audio.nix`
- `graphics.nix`
- `graphics-workstation.nix`
- `kde.nix`
- `vr.nix`
- `flatpak.nix`
- `logitech.nix`
- `power.nix`
- `power-workstation.nix`
- Steam/gamescope/gamemode settings

What to learn here:

- A NixOS host is just a module importing other modules.
- Deleting an import removes that whole behavior from the system.
- `system.stateVersion` is not the NixOS version. It is a compatibility marker
  for stateful defaults. Do not casually bump it after install.

## Phase 3: Build A NixOS Server Base

Goal: create a reusable server foundation before Kubernetes.

Start with these base concerns:

- Nix settings
- users
- SSH
- firewall
- updates and garbage collection
- logs
- disk health
- basic hardening

Keep the server base split into small modules. For learning, this is valuable
because it teaches the NixOS option tree.

Suggested base module split:

```text
modules/nixos/base/default.nix
modules/nixos/base/nix.nix
modules/nixos/base/users.nix
modules/nixos/base/ssh.nix
modules/nixos/base/networking.nix
modules/nixos/base/maintenance.nix
modules/nixos/base/hardening.nix
```

`modules/nixos/base/default.nix` can simply import the pieces:

```nix
{
  imports = [
    ./nix.nix
    ./users.nix
    ./ssh.nix
    ./networking.nix
    ./maintenance.nix
    ./hardening.nix
  ];
}
```

A server SSH module should explicitly enable OpenSSH:

```nix
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
}
```

A server user module should set up your admin user:

```nix
{ pkgs, username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # Add your public SSH key here.
    ];
  };

  programs.fish.enable = true;
}
```

What to learn here:

- `services.openssh.enable` starts the SSH server.
- `programs.ssh.enable` in Home Manager configures the SSH client.
- `networking.firewall.allowedTCPPorts` opens host firewall ports.
- NixOS modules merge option values, which is why separate modules can each add
  firewall ports or packages.

## Phase 4: Install The Server

Goal: get the old workstation booting as a headless NixOS server.

High-level path:

1. Back up anything on the old workstation.
2. Boot the NixOS installer.
3. Partition and format disks.
4. Generate hardware config.
5. Copy the generated hardware config into this repo.
6. Install using the flake target.
7. Reboot and SSH in from the MacBook.

The existing `hosts/server/hardware.nix` is a placeholder. It contains fake
UUIDs and will not boot as-is. Regenerate it on the actual machine:

```bash
sudo nixos-generate-config --show-hardware-config
```

Then put the output into:

```text
hosts/server/hardware.nix
```

For a first server, keep disk layout simple. A good learning layout is:

- EFI partition mounted at `/boot`
- one root filesystem mounted at `/`
- optional btrfs subvolumes if you want snapshots later
- zram swap enabled

Do not add Kubernetes storage complexity yet. First make the host boot and
survive rebuilds.

Install command shape:

```bash
sudo nixos-install --flake .#server
```

After reboot, from the MacBook:

```bash
ssh server
```

or:

```bash
ssh gabrielfaucher@server.local
```

depending on DNS/mDNS.

What to learn here:

- Hardware config is machine-specific.
- The flake target is machine identity.
- Rebuilds are safer once SSH works.

## Phase 5: Make Remote Rebuilds Boring

Goal: manage the server from the MacBook.

From the MacBook, you want a workflow like:

```bash
git pull
nix flake check
nixos-rebuild switch --flake .#server --target-host server --use-remote-sudo
```

This teaches an important Nix idea: the config can live on your MacBook while
the activation happens on the server.

Useful development loop:

```bash
nix flake check
nixos-rebuild build --flake .#server
nixos-rebuild switch --flake .#server --target-host server --use-remote-sudo
```

If builds are slow on the server, later you can build locally or use a remote
builder. Do not optimize this before the basic loop works.

What to learn here:

- `build` creates a system closure without activating it.
- `switch` builds and activates.
- `--target-host` activates on a remote machine.
- `--use-remote-sudo` lets your normal user run the activation with sudo.

## Phase 6: Unify Home Manager

Goal: keep one Home Manager entrypoint without losing the Mac setup.

The future should be:

```text
modules/home/default.nix
modules/home/common/*
modules/home/platforms/darwin.nix
modules/home/platforms/linux.nix
modules/home/profiles/macbook.nix
modules/home/profiles/server-admin.nix
```

Shared home modules:

- shell
- git
- ssh client
- tmux
- Neovim
- CLI tools
- Kubernetes client tools

Darwin-only home modules:

- `/opt/homebrew/bin` path additions
- macOS-specific packages or config
- Ghostty assumptions if installed by Homebrew

Linux-only home modules:

- xdg user dirs
- Linux MIME apps
- Firefox desktop settings
- KDE or desktop settings, if you ever bring Linux desktop back

Server-admin profile:

- SSH client
- tmux
- Neovim
- kubectl
- k9s
- helm
- flux or argocd CLI
- restic
- age/sops tooling

The server itself does not need a full graphical user home. Keep it lean.

What to learn here:

- Home Manager manages user files and user programs.
- NixOS manages system services and boot-level behavior.
- `pkgs.stdenv.isDarwin` and `pkgs.stdenv.isLinux` are useful in Home Manager.

## Phase 7: Private Access Without Tailscale

Goal: get reliable admin access without installing an overlay VPN that conflicts
with Tunnelblick or the work OpenVPN setup.

Tailscale is explicitly out of scope for this setup. Do not install it on the
MacBook and do not enable it on the server.

Start with the simplest access model:

- MacBook and server on the same LAN.
- Server gets a predictable LAN IP from the router using a DHCP reservation.
- MacBook connects by SSH to that LAN IP or a local DNS name.
- Kubernetes API is reachable only from the LAN while learning.
- Public internet exposure is limited to HTTP/HTTPS ingress later.

Router setup:

1. Find the server's network MAC address after install.
2. Add a DHCP reservation in the router.
3. Pick a stable address, for example `192.168.1.20`.
4. Optionally add a local DNS name such as `server.home.arpa`.

MacBook SSH config example:

```sshconfig
Host server
  HostName 192.168.1.20
  User gabrielfaucher
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

NixOS server SSH module:

```nix
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
}
```

Remote access when away from home should be a separate decision. Options:

- Use only HTTPS public apps remotely, and do admin work when back on LAN.
- Use a router-provided VPN if it does not conflict with Tunnelblick.
- Use a bastion/VPS with SSH reverse tunnels later, if remote admin becomes
  important.

Do not expose SSH or the Kubernetes API publicly as the default learning path.
If you later expose SSH, restrict it hard:

- SSH keys only
- no root login
- fail2ban or equivalent
- non-default port only as a noise reducer, not as security
- firewall allowlist if your source IP is predictable

What to learn here:

- Private admin access and public app access are different problems.
- A stable LAN IP is enough for the first NixOS and Kubernetes learning loop.
- Avoiding network-layer conflicts on the MacBook is more important than a
  fashionable overlay network.
- Kubernetes API access should stay private.

## Phase 8: Choose Kubernetes Distribution

Recommendation: use k3s first.

Why k3s:

- packaged well on NixOS
- simpler than kubeadm
- good for one-machine homelab clusters
- includes a lightweight control plane
- easy to replace later if you outgrow it

Avoid starting with:

- kubeadm, unless your goal is specifically to learn upstream cluster assembly
- Talos, because it moves OS management away from NixOS
- multi-node Kubernetes, until the single node is boring

Basic NixOS k3s module:

```nix
{
  services.k3s = {
    enable = true;
    role = "server";
  };

  networking.firewall.allowedTCPPorts = [
    6443 # Kubernetes API
  ];
}
```

Do not expose 6443 publicly. While learning, access the Kubernetes API from the
LAN only.

After rebuild on the server:

```bash
sudo k3s kubectl get nodes
sudo k3s kubectl get pods -A
```

Copy kubeconfig to the MacBook later:

```bash
sudo cat /etc/rancher/k3s/k3s.yaml
```

Then edit the `server:` address in the kubeconfig to use the server's LAN IP or
local DNS name.

What to learn here:

- The Kubernetes API server is the control interface.
- `kubectl` talks to the API server using kubeconfig.
- A node is the machine running workloads.
- Pods are the smallest deployable workload units.
- Deployments manage replicated pods.
- Services give pods stable network identities.
- Ingress exposes HTTP services.

## Phase 9: Decide How Public Traffic Enters

Goal: expose only HTTP/HTTPS publicly at first.

Recommended public ports:

- TCP 80
- TCP 443

Avoid exposing:

- Kubernetes API port 6443
- databases
- dashboards
- random app ports
- SSH, unless you have made a deliberate hardened remote-admin decision

Ingress choices:

- Traefik: k3s includes it by default. Good enough to start.
- ingress-nginx: common, well documented, slightly more explicit.
- Caddy: excellent for simple reverse proxying, but less Kubernetes-native.

For learning Kubernetes, start with Traefik or ingress-nginx. Since k3s ships
with Traefik, the easiest path is to use the default first, learn the concepts,
and replace it later only if you have a reason.

Firewall module:

```nix
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
```

Router/firewall outside the server:

- forward public TCP 80 to the server
- forward public TCP 443 to the server
- do not forward 6443
- do not forward databases

What to learn here:

- DNS points names to your public IP.
- Port forwarding sends public traffic to the server.
- Ingress routes hostnames and paths to Kubernetes Services.
- Services route to Pods.

## Phase 10: TLS Certificates

Goal: get real HTTPS without manually copying certificates.

Use cert-manager once ingress works.

Concepts:

- cert-manager watches Kubernetes resources.
- An Issuer or ClusterIssuer describes how to request certificates.
- A Certificate resource asks for a certificate.
- Ingress annotations can ask cert-manager to create certificates.

For public services, use Let's Encrypt HTTP-01 validation first. That requires:

- public DNS points to your home/server IP
- port 80 reaches the ingress controller
- the service is reachable from the public internet

Later, DNS-01 is better if:

- you want wildcard certificates
- your services are not publicly reachable during validation
- your DNS provider has a good API

What to learn here:

- TLS is separate from the app.
- cert-manager stores certs as Kubernetes Secrets.
- Ingress uses those Secrets to serve HTTPS.

## Phase 11: Secrets Strategy

Goal: stop secrets from becoming random files on the server.

Current repo note:

- There are encrypted age secrets in `secrets/`.
- `secrets/default.nix` expects agenix-style integration.
- `flake.nix` currently does not include agenix.

You need two layers of secrets:

1. NixOS/system secrets

   Use agenix or sops-nix for things the operating system needs:

   - restic passwords
   - service tokens
   - backup credentials

2. Kubernetes application secrets

   Use one of:

   - SOPS + Flux
   - Sealed Secrets
   - External Secrets Operator
   - manual `kubectl create secret` while learning

Recommended learning path:

1. Start with manual Kubernetes Secrets for toy apps.
2. Add SOPS once you understand what the Secrets look like.
3. Move to Flux-managed encrypted secrets when GitOps begins.

What to learn here:

- Nix secrets and Kubernetes secrets solve related but different problems.
- Never commit plaintext secrets.
- Kubernetes Secrets are base64-encoded, not encrypted by default.
- Encrypted GitOps requires a controller or workflow that can decrypt safely.

## Phase 12: Persistent Storage

Goal: understand where app data lives before hosting anything important.

For a single-node server, start simple:

- local-path provisioner from k3s for learning
- explicit host paths for services you care about
- real backups before real data

Storage concepts:

- PersistentVolume: actual storage.
- PersistentVolumeClaim: an app's request for storage.
- StorageClass: how Kubernetes creates storage dynamically.

For early learning, deploy apps that are easy to recreate:

- whoami
- nginx
- echo server
- static site
- uptime-kuma only after backups exist

Avoid as first apps:

- databases with valuable data
- mail servers
- identity providers
- anything storing irreplaceable files

What to learn here:

- Containers are disposable.
- Volumes are where state lives.
- Backups matter more than clever storage classes.

## Phase 13: Backups

Goal: have restore confidence before hosting serious services.

The backup goal is not "copy files somewhere". The goal is:

- the server can die
- the boot disk can die
- Kubernetes can be reinstalled
- one app can be restored with its data
- you know the restore commands because you have already practiced them

For this server, use restic first. It is encrypted, deduplicated, incremental,
widely supported, and fits NixOS well.

Recommended target:

```text
NixOS server
  -> restic
  -> Hetzner Storage Box over SFTP
```

Other valid targets:

- Backblaze B2 if you want S3-compatible object storage.
- rsync.net if you want a very clean SSH/Borg/Unix filesystem experience.
- Wasabi if predictable S3-like pricing matters more than absolute cheapness.

Start with Hetzner Storage Box unless you have a reason not to. It supports
Restic, BorgBackup, rsync over SSH, SFTP, SCP, WebDAV, and snapshots. That makes
it a good learning target because the storage is simple and inspectable.

### Backup Layers

Think in layers:

1. Git layer

   This repo should be pushed to a remote Git host. That backs up the
   declarative system shape, not the server data.

2. NixOS/system layer

   Back up operating-system state that is not fully represented in Git:

   - `/etc`
   - selected `/var/lib` paths
   - k3s state
   - service state
   - logs only if you need them for audit/debugging

3. Kubernetes manifest layer

   Eventually this is your `kubernetes/` GitOps directory. Git backs this up.
   Until then, export or keep all YAML manifests in the repo.

4. Kubernetes data layer

   Back up persistent volumes and database dumps. This is the important part.

5. Secret material layer

   Back up encrypted secrets, not plaintext secrets. Make sure you also know
   where the age/SOPS private key lives, because encrypted backups are useless
   if the decryption key is gone.

### What To Back Up First

Before Kubernetes:

- `/etc`
- `/home/${username}` if you keep meaningful admin files on the server
- this repo, if cloned on the server
- any hand-created service files or config

After k3s:

- `/var/lib/rancher/k3s/server/db`
- `/var/lib/rancher/k3s/server/manifests`
- persistent volume directories
- database dumps
- selected app config directories

For k3s, be careful with broad `/var/lib/rancher/k3s` backups. It can include
runtime/cache/container state that is less useful and may be large. The exact
paths depend on how k3s, containerd, and local-path storage are configured.
Learn what is in the directory before blindly backing up all of it:

```bash
sudo du -h -d 2 /var/lib/rancher/k3s
sudo find /var/lib/rancher/k3s -maxdepth 3 -type d
```

For a first single-node setup, it is fine to start wider, then tighten excludes
once you understand the layout.

### What Not To Back Up

Usually exclude:

- `/nix/store`
- `/proc`
- `/sys`
- `/dev`
- `/run`
- `/tmp`
- `/var/tmp`
- container image caches
- container runtime snapshots
- Docker/containerd caches
- systemd coredumps
- build outputs
- `node_modules`
- `.cache`

Do not back up `/nix/store` for normal server recovery. Your flake rebuilds it.
Backing it up wastes space and makes restores noisy.

### Restic Repository Setup

The first learning exercise should be manual. Do not start declarative.

On the server, install restic temporarily or add it to the server package list:

```nix
environment.systemPackages = with pkgs; [
  restic
];
```

Create local secret files manually at first:

```bash
sudo mkdir -p /etc/restic
sudo chmod 700 /etc/restic
sudoedit /etc/restic/password
sudo chmod 600 /etc/restic/password
```

For Hetzner Storage Box over SFTP, create an environment file:

```bash
sudoedit /etc/restic/hetzner-env
sudo chmod 600 /etc/restic/hetzner-env
```

Example contents:

```bash
RESTIC_REPOSITORY=sftp:uXXXXXX@uXXXXXX.your-storagebox.de:/backups/server
```

Then initialize the repository:

```bash
sudo restic --password-file /etc/restic/password \
  -r sftp:uXXXXXX@uXXXXXX.your-storagebox.de:/backups/server \
  init
```

If using Backblaze B2 instead, the environment shape is different:

```bash
B2_ACCOUNT_ID=...
B2_ACCOUNT_KEY=...
RESTIC_REPOSITORY=b2:bucket-name:/server
```

Do not commit these plaintext files. Later, move them into agenix or sops-nix.

### First Manual Backup

Create a tiny test directory:

```bash
sudo mkdir -p /srv/backup-test
echo "hello from server" | sudo tee /srv/backup-test/hello.txt
```

Run the first backup:

```bash
sudo restic \
  --password-file /etc/restic/password \
  -r sftp:uXXXXXX@uXXXXXX.your-storagebox.de:/backups/server \
  backup /srv/backup-test
```

List snapshots:

```bash
sudo restic \
  --password-file /etc/restic/password \
  -r sftp:uXXXXXX@uXXXXXX.your-storagebox.de:/backups/server \
  snapshots
```

Restore it:

```bash
sudo mkdir -p /tmp/restore-test
sudo restic \
  --password-file /etc/restic/password \
  -r sftp:uXXXXXX@uXXXXXX.your-storagebox.de:/backups/server \
  restore latest --target /tmp/restore-test
cat /tmp/restore-test/srv/backup-test/hello.txt
```

Only after this works should you automate backups.

### NixOS Backup Module

Restic belongs in a dedicated server backup module:

```text
modules/nixos/services/backups.nix
```

First version:

```nix
{
  config,
  pkgs,
  username,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    restic
  ];

  services.restic.backups.hetzner = {
    initialize = true;

    passwordFile = "/etc/restic/password";
    environmentFile = "/etc/restic/hetzner-env";

    paths = [
      "/etc"
      "/home/${username}"
      "/srv"
      "/var/lib/rancher/k3s/server/db"
      "/var/lib/rancher/k3s/server/manifests"
    ];

    exclude = [
      "/home/${username}/.cache"
      "/home/${username}/.local/share/Trash"
      "/var/lib/docker"
      "/var/lib/containerd"
      "/var/lib/rancher/k3s/agent/containerd"
      "/var/lib/systemd/coredump"
      "node_modules"
      ".direnv"
      ".venv"
      "target"
      "result"
      "*.tmp"
      "*.swp"
    ];

    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
      "--keep-yearly 2"
    ];

    extraBackupArgs = [
      "--verbose"
      "--exclude-caches"
      "--one-file-system"
    ];
  };
}
```

Important: this assumes the repository and credential files exist. When you move
to agenix/sops-nix, those files should be produced by encrypted secrets instead
of hand-created files in `/etc/restic`.

### Secret Handling For Backups

There are three important backup secrets:

- restic repository password
- remote storage credentials
- age/SOPS private key used to decrypt repo secrets

The restic password is critical. Without it, the backup repository is useless.

Recommended progression:

1. Start with manual files in `/etc/restic`.
2. Prove backup and restore.
3. Add agenix or sops-nix to the flake.
4. Move `/etc/restic/password` and `/etc/restic/hetzner-env` into encrypted
   NixOS secrets.
5. Store the age/SOPS private key somewhere separate from the server:

   - password manager
   - encrypted USB drive
   - printed emergency recovery copy for the key material if appropriate

Do not store the only decryption key only on the server being backed up.

### Kubernetes Persistent Volumes

k3s usually uses local-path storage for simple single-node clusters. That means
persistent volumes are directories on the server filesystem.

Find them:

```bash
kubectl get pv
kubectl describe pv <name>
```

Look for host paths such as:

```text
/var/lib/rancher/k3s/storage/...
```

For learning, write down every app's data path in a small table:

```text
App          Namespace   Data path                                Backup method
whoami       default     none                                     none
uptime-kuma  monitoring  /var/lib/rancher/k3s/storage/...         restic file backup
postgres     app         PVC + logical dump                       pg_dump + restic
```

The point is to know which data is file-level safe and which data needs an app
aware dump.

### Database Backups

Databases deserve special treatment.

A raw file backup of a running database can be inconsistent. Some databases can
recover from this, some cannot, and "probably fine" is a bad backup strategy.

Prefer logical dumps:

- PostgreSQL: `pg_dump` or `pg_dumpall`
- MariaDB/MySQL: `mysqldump` or `mariadb-dump`
- SQLite: `.backup` or app-specific export if the app provides one

Store dumps under a backup-friendly path:

```text
/srv/backups/databases/
```

Then restic backs up that directory.

Example PostgreSQL dump pattern:

```bash
mkdir -p /srv/backups/databases
pg_dump -h localhost -U app appdb > /srv/backups/databases/appdb.sql
```

For Kubernetes-hosted databases, you can run dumps as:

- a Kubernetes CronJob
- a systemd timer that uses `kubectl exec`
- an app-specific backup job if the chart provides one

Start simple. For the first database-backed app, write the dump and restore
commands manually in the app's notes before automating them.

### Backup Timing

Start with:

- daily restic backup at night
- weekly repository check
- monthly restore drill

Do not run huge prune/check jobs every night while learning. They can be slow.

NixOS timers to understand:

```bash
systemctl list-timers
systemctl status restic-backups-hetzner.service
journalctl -u restic-backups-hetzner.service
```

Manual run:

```bash
sudo systemctl start restic-backups-hetzner.service
```

### Retention Policy

Start with:

```text
7 daily
4 weekly
6 monthly
2 yearly
```

That gives you:

- recent rollback points
- a few months of history
- long-term safety against slow accidental corruption

For a tiny server, this is usually cheap because restic deduplicates unchanged
data.

### Monitoring Backups

At minimum, learn to inspect the timer:

```bash
systemctl list-timers '*restic*'
journalctl -u restic-backups-hetzner.service --since yesterday
```

Later options:

- send systemd failure email
- use a healthchecks.io ping
- expose backup status in Uptime Kuma
- send notifications through ntfy, Gotify, or Pushover

Simple healthchecks pattern:

```text
backup starts
  -> run restic
  -> if success, ping healthchecks success URL
  -> if failure, systemd marks unit failed
```

Do this later. First learn the local logs.

### Restore Drills

Practice restores before real services matter.

Drill 1: one file

```bash
restic restore latest --target /tmp/restore-test --include /etc/ssh/sshd_config
```

Drill 2: one app volume

1. Stop the app.
2. Restore its data to `/tmp/restore-test`.
3. Compare the restored files.
4. Do not overwrite production data yet.

Drill 3: database

1. Dump database.
2. Back it up.
3. Restore dump into a temporary database.
4. Verify tables and row counts.

Drill 4: disaster simulation

Pretend the server disk died. Write the steps to rebuild:

1. Install NixOS from `.#server`.
2. Restore `/etc` pieces if needed.
3. Restore k3s state or redeploy cluster.
4. Recreate Kubernetes apps from Git.
5. Restore persistent volumes or database dumps.
6. Repoint DNS if hardware/IP changed.

Do not actually wipe the server for the first drill. Just write and test pieces
of the process.

### Full Server Restore Strategy

There are two possible restore models:

1. Rebuild-first restore

   Reinstall NixOS from the flake, then restore app data. This is the preferred
   model for NixOS because system config is declarative.

2. Image-style restore

   Restore a whole disk or filesystem snapshot. This is sometimes faster, but it
   hides what matters and is less educational.

Use rebuild-first. It teaches Nix properly and keeps the backup smaller.

### Backup Checklist Before Hosting Real Data

Do not host important services until all of these are true:

- restic repository initialized
- daily backup timer works
- prune policy configured
- one file restore tested
- one app volume restore tested
- database dump and restore tested, if using a database
- backup password stored outside the server
- storage provider credentials stored outside the server
- age/SOPS private key recoverable outside the server
- notes exist for restoring the first important app

### Commands To Understand

Restic:

```bash
restic snapshots
restic backup /path
restic restore latest --target /tmp/restore-test
restic check
restic forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 6
```

NixOS/systemd:

```bash
systemctl list-timers '*restic*'
systemctl status restic-backups-hetzner.service
journalctl -u restic-backups-hetzner.service
sudo systemctl start restic-backups-hetzner.service
```

Kubernetes storage:

```bash
kubectl get pv
kubectl get pvc -A
kubectl describe pv <name>
```

What to learn here:

- A backup that has never been restored is only a hope.
- Kubernetes manifests are not enough; app data must be backed up too.
- Database backups should usually be logical dumps, not only raw files.
- NixOS lets you rebuild the machine; backups restore the non-declarative state.
- The decryption key is part of the backup system.

## Phase 14: GitOps Later, Not First

Goal: learn Kubernetes manually before automating it.

Manual first:

```bash
kubectl apply -f app.yaml
kubectl get pods
kubectl describe pod ...
kubectl logs ...
kubectl delete -f app.yaml
```

Then GitOps:

- Flux is a good fit because you already have CLI tooling in the repo.
- ArgoCD is more visual and heavier.

Recommended path:

1. Create a `kubernetes/` directory later.
2. Add plain manifests for toy apps.
3. Convert to Kustomize.
4. Install Flux.
5. Let Flux reconcile the repo.
6. Add encrypted secrets.

Possible future layout:

```text
kubernetes/
  clusters/
    server/
      flux-system/
      apps/
  apps/
    whoami/
      base/
      overlays/
        server/
    uptime-kuma/
      base/
      overlays/
        server/
```

What to learn here:

- `kubectl apply` teaches the object model.
- Kustomize teaches composition.
- Flux teaches reconciliation.
- GitOps should make a known-good manual process repeatable.

## Suggested First Learning Apps

Deploy these in order:

1. `whoami`

   Teaches Deployment, Service, Ingress.

2. static nginx page

   Teaches ConfigMap and simple HTTP routing.

3. uptime-kuma

   Teaches persistent volume claims and backups.

4. home dashboard

   Teaches multiple ingresses and internal links.

5. one database-backed app

   Teaches database state, restore drills, and upgrade caution.

## What To Remove From The Old Workstation Config

When converting the old workstation into `server`, remove these categories:

- graphical session
- display manager
- KDE Plasma
- audio stack
- Bluetooth desktop assumptions
- Steam/gaming
- VR
- Flatpak desktop apps
- Logitech desktop tooling
- laptop/workstation power tuning
- browser and MIME defaults from Linux desktop Home Manager
- Teams/Zoom workarounds

Keep or adapt these categories:

- Nix settings
- user setup
- SSH
- firewall
- hardening
- maintenance
- smartd
- btrfs scrub, if using btrfs
- restic backup plan

## What To Keep On The MacBook

MacBook should keep:

- nix-darwin system defaults
- Homebrew casks for macOS GUI apps
- Home Manager for shared CLI environment
- Kubernetes client tools
- SSH config
- editor, tmux, shell

The MacBook should not run the server workloads. It should be the control
machine: edit repo, commit changes, rebuild server, operate Kubernetes.

## Milestones

Use these as checkpoints:

1. Flake exposes only `macbook` and `server`.
2. MacBook rebuild still works.
3. Server config evaluates.
4. Server boots NixOS from `.#server`.
5. MacBook can SSH to server.
6. Remote rebuild works.
7. Server has a stable LAN IP or local DNS name.
8. k3s node is Ready.
9. `kubectl` from MacBook works over LAN.
10. First internal test app works.
11. First public HTTPS app works.
12. Restic backup and restore test succeeds.
13. First GitOps-managed app works.

## Recommended Task Order

### Task 1: Document and preserve architecture

- Keep this guide in `docs/plans`.
- Once `bd` is available, create a Beads knowledge issue for it.

### Task 2: Refactor flake helpers

- Add `mkDarwinHost`.
- Add `mkNixosHost`.
- Keep behavior unchanged for MacBook.

### Task 3: Keep Mac host in `hosts/macbook/default.nix`

- Keep the Mac host file thin.
- Put Darwin system behavior in `modules/darwin`.
- Keep Home Manager behavior in `modules/home`.

### Task 4: Maintain shared Home Manager entrypoint

- Keep `modules/home/default.nix` as the shared entrypoint.
- Keep Darwin-only config under `modules/home/platforms/darwin.nix`.
- Keep Linux-only config under `modules/home/platforms/linux.nix`.
- Put role-specific user tooling under `modules/home/profiles`.

### Task 5: Create NixOS server base modules

- Keep reusable server-safe pieces in `modules/nixos/base`.
- Do not import desktop modules.

### Task 6: Create `hosts/server`

- Use old workstation hardware as the starting point.
- Replace fake UUIDs after install.
- Set `networking.hostName = "server"`.

### Task 7: Install and verify server

- Boot old workstation with NixOS installer.
- Generate real hardware config.
- Install `.#server`.
- SSH from MacBook.

### Task 8: Add k3s

- Add `modules/nixos/services/k3s.nix`.
- Verify node readiness.
- Copy kubeconfig to MacBook.

### Task 9: Add ingress and TLS

- Start with k3s Traefik.
- Add cert-manager.
- Expose one harmless app.

### Task 10: Add backups

- Pick the remote backup target. Start with Hetzner Storage Box unless you have
  a reason to use S3-compatible storage.
- Configure restic manually first.
- Initialize the repository.
- Back up and restore `/srv/backup-test`.
- Move restic configuration into `modules/nixos/services/backups.nix`.
- Add encrypted secret management for the restic password and remote credentials.
- Identify Kubernetes persistent volume paths.
- Add database dump jobs before hosting database-backed apps.
- Run a file restore, app-volume restore, and database restore drill before
  trusting the setup.

## Personal Learning Notes

When learning Nix, ask these questions about every file:

- Is this a host, a role, or a reusable module?
- Is this system-level or user-level?
- Is this Darwin-only, NixOS-only, or shared Home Manager?
- Does this belong on the server, the MacBook, or both?
- Can I evaluate it before I switch to it?

When learning Kubernetes, ask these questions about every app:

- What image runs?
- What environment/config does it need?
- Does it need persistent data?
- How is it reached inside the cluster?
- How is it reached from outside the cluster?
- How is it backed up?
- How would I restore it on a fresh server?

## Immediate Next Step

Do not start with k3s. Start with the repo shape:

1. Refactor `flake.nix` so the intended outputs are `macbook` and `server`.
2. Move the current Mac host file to `hosts/macbook/default.nix`.
3. Create a minimal `hosts/server/default.nix`.
4. Make `nix flake show` show both machines.

That gives you the skeleton. Kubernetes comes after the old workstation can boot
as a boring, reachable NixOS server.
