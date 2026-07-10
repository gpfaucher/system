{ pkgs, ... }:

let
  podinfoManifest = pkgs.writeText "uptime-podinfo.yaml" ''
    apiVersion: v1
    kind: Namespace
    metadata:
      name: uptime
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: uptime-smoke
      namespace: uptime
      labels:
        app.kubernetes.io/name: podinfo
    spec:
      replicas: 1
      selector:
        matchLabels:
          app.kubernetes.io/name: podinfo
      template:
        metadata:
          labels:
            app.kubernetes.io/name: podinfo
        spec:
          containers:
            - name: podinfo
              image: ghcr.io/stefanprodan/podinfo:6.9.1
              ports:
                - name: http
                  containerPort: 9898
              readinessProbe:
                httpGet:
                  path: /readyz
                  port: http
              livenessProbe:
                httpGet:
                  path: /healthz
                  port: http
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: uptime-smoke
      namespace: uptime
    spec:
      selector:
        app.kubernetes.io/name: podinfo
      ports:
        - name: http
          port: 80
          targetPort: http
    ---
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: uptime-smoke
      namespace: uptime
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-http01
        traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    spec:
      tls:
        - hosts:
            - uptime.faucher.dev
          secretName: uptime-faucher-dev-tls
      rules:
        - host: uptime.faucher.dev
          http:
            paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: uptime-smoke
                    port:
                      name: http
  '';
in
{
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
  ];

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--tls-san=100.88.195.11"
    ];
    manifests.uptime-podinfo.source = podinfoManifest;
  };

  networking.firewall.allowedTCPPorts = [
    6443
  ];
}
