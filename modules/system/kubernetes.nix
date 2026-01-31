{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Kubernetes cluster configuration
  # For single-node setup, master and node are on the same machine
  kubeMasterIP = "127.0.0.1";
  kubeMasterHostname = "api.kube";
  kubeMasterAPIServerPort = 6443;
in
{
  # ============================================
  # Full Kubernetes Cluster (Master + Node)
  # ============================================
  # Single-node cluster for learning and development
  # Based on NixOS native Kubernetes module

  # Resolve master hostname locally
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # Kubernetes packages
  environment.systemPackages = with pkgs; [
    # Core Kubernetes tools
    kubectl        # Kubernetes CLI
    kubernetes     # Full Kubernetes suite
    kompose        # Convert docker-compose to k8s

    # Package management
    kubernetes-helm # Helm package manager

    # Development & debugging
    k9s            # Kubernetes TUI
    stern          # Multi-pod log tailing
    kubectx        # Context/namespace switcher
    lens           # Kubernetes IDE (optional GUI)

    # Container tools
    containerd     # Container runtime
    nerdctl        # Docker-compatible CLI for containerd
    buildkit       # Container image builder
  ];

  # Kubernetes services configuration
  services.kubernetes = {
    # Run both master and node roles on this machine
    roles = [ "master" "node" ];

    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";

    # Use easy certificate generation (good for single-node/learning)
    easyCerts = true;

    # API server configuration
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;

      # Allow privileged containers (needed for some workloads)
      extraOpts = "--allow-privileged=true";
    };

    # Kubelet configuration
    kubelet = {
      # Allow swap (NixOS uses zram)
      extraOpts = "--fail-swap-on=false";
    };

    # Enable CoreDNS for service discovery
    addons.dns.enable = true;

    # Flannel CNI for pod networking
    flannel.enable = true;
  };

  # Container runtime configuration
  virtualisation.containerd = {
    enable = true;

    # NVIDIA runtime for GPU workloads in containers
    settings = {
      plugins."io.containerd.grpc.v1.cri" = {
        containerd.runtimes.nvidia = {
          runtime_type = "io.containerd.runc.v2";
          options.BinaryName = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
        };
      };
    };
  };

  # Docker for local development (optional, Kubernetes uses containerd)
  virtualisation.docker = {
    enable = true;

    # Use containerd as storage backend
    daemon.settings = {
      features.containerd-snapshotter = true;
    };
  };

  # NVIDIA GPU support in containers (used by both Docker and Kubernetes)
  # Already enabled in nvidia-desktop.nix via hardware.nvidia-container-toolkit.enable

  # Firewall rules for Kubernetes
  networking.firewall = {
    allowedTCPPorts = [
      6443  # Kubernetes API server
      2379  # etcd client
      2380  # etcd peer
      10250 # Kubelet API
      10251 # kube-scheduler
      10252 # kube-controller-manager
      10255 # Kubelet read-only
    ];

    # Allow all traffic from pod network (flannel default)
    trustedInterfaces = [ "flannel.1" "cni0" ];
  };

  # Enable IP forwarding for pod networking
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
  };

  # Load bridge netfilter module
  boot.kernelModules = [ "br_netfilter" "overlay" ];

  # Convenience: link kubeconfig to user home
  # Run after first boot: ln -s /etc/kubernetes/cluster-admin.kubeconfig ~/.kube/config
  system.activationScripts.kubeconfig = ''
    mkdir -p /home/gabriel/.kube
    if [ -f /etc/kubernetes/cluster-admin.kubeconfig ]; then
      ln -sf /etc/kubernetes/cluster-admin.kubeconfig /home/gabriel/.kube/config
      chown gabriel:users /home/gabriel/.kube/config
    fi
  '';
}
