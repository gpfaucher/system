{ pkgs, ... }:

let
  certManagerManifest = pkgs.writeText "cert-manager.yaml" ''
    apiVersion: v1
    kind: Namespace
    metadata:
      name: cert-manager
    ---
    apiVersion: helm.cattle.io/v1
    kind: HelmChart
    metadata:
      name: cert-manager
      namespace: kube-system
    spec:
      repo: https://charts.jetstack.io
      chart: cert-manager
      version: v1.18.2
      targetNamespace: cert-manager
      createNamespace: true
      valuesContent: |-
        crds:
          enabled: true
    ---
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-http01
    spec:
      acme:
        email: admin@faucher.dev
        server: https://acme-v02.api.letsencrypt.org/directory
        privateKeySecretRef:
          name: letsencrypt-http01-account-key
        solvers:
          - http01:
              ingress:
                class: traefik
  '';
in
{
  services.k3s.manifests.cert-manager.source = certManagerManifest;
}
