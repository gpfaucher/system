{ pkgs, ... }:

let
  uptimeSmokeManifest = pkgs.writeText "uptime-smoke.yaml" ''
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
        app.kubernetes.io/name: uptime-smoke
    spec:
      replicas: 1
      selector:
        matchLabels:
          app.kubernetes.io/name: uptime-smoke
      template:
        metadata:
          labels:
            app.kubernetes.io/name: uptime-smoke
        spec:
          containers:
            - name: whoami
              image: traefik/whoami:v1.11.0
              ports:
                - name: http
                  containerPort: 80
              readinessProbe:
                httpGet:
                  path: /
                  port: http
              livenessProbe:
                httpGet:
                  path: /
                  port: http
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: uptime-smoke
      namespace: uptime
    spec:
      selector:
        app.kubernetes.io/name: uptime-smoke
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
        traefik.ingress.kubernetes.io/router.entrypoints: web
    spec:
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
    manifests.uptime-smoke.source = uptimeSmokeManifest;
  };

  networking.firewall.allowedTCPPorts = [
    6443
  ];
}
