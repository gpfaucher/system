# NixOS Server Bootstrap From This Repo

Goal: start from the fresh NixOS GNOME install, get SSH working, copy this repo to the server, then let `.#server` manage the machine.

## 1. On the fresh server, enable temporary SSH

Edit `/etc/nixos/configuration.nix` on the server and add:

```nix
services.openssh.enable = true;
networking.firewall.allowedTCPPorts = [ 22 ];
```

For this temporary phase only, password SSH is acceptable if you are on a trusted LAN and physically near the machine:

```nix
services.openssh.settings.PasswordAuthentication = true;
```

Apply it:

```bash
sudo nixos-rebuild switch
```

Find the server IP:

```bash
ip addr
```

## 2. From the Mac, copy or clone the repo

If GitHub access is ready on the server:

```bash
ssh gabrielfaucher@SERVER_IP
nix shell nixpkgs#git
git clone REPO_URL ~/system
cd ~/system
```

If cloning is annoying, copy the repo from the Mac instead:

```bash
rsync -av --exclude .git/result --exclude result ~/Developer/system/ gabrielfaucher@SERVER_IP:~/system/
```

## 3. Generate the real hardware config on the server

From `~/system` on the server:

```bash
sudo nixos-generate-config --show-hardware-config > hosts/server/hardware.nix
```

Check the fresh install's generated `/etc/nixos/configuration.nix` and keep `system.stateVersion` in `hosts/server/default.nix` aligned with that value.

## 4. Test before switching permanently

```bash
sudo nixos-rebuild test --flake .#server
```

Open a second terminal from the Mac and confirm SSH still works:

```bash
ssh gabrielfaucher@SERVER_IP
```

## 5. Switch to repo-managed config

```bash
sudo nixos-rebuild switch --flake .#server
```

Then enroll the server in Tailscale:

```bash
sudo tailscale up --ssh
```

After Tailscale works, use the Tailscale name or IP for remote access instead of depending on router changes.

## 6. Future updates

Edit on the Mac, commit and push, then on the server:

```bash
cd ~/system
git pull
sudo ./scripts/rebuild.sh server
```

Keep `ingress.nix` and `k3s.nix` disabled until SSH and Tailscale are boringly reliable.
