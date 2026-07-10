{ pkgs, ... }:

let
  argocdExposureManifest = pkgs.writeText "argocd-exposure.yaml" ''
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: argocd-cmd-params-cm
      namespace: argocd
      labels:
        app.kubernetes.io/name: argocd-cmd-params-cm
        app.kubernetes.io/part-of: argocd
    data:
      server.insecure: "true"
    ---
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: argocd-server
      namespace: argocd
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-http01
        traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    spec:
      tls:
        - hosts:
            - argo.faucher.dev
          secretName: argo-faucher-dev-tls
      rules:
        - host: argo.faucher.dev
          http:
            paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: argocd-server
                    port:
                      name: http
  '';
in
{
  services.k3s.manifests.argocd-exposure.source = argocdExposureManifest;
}
