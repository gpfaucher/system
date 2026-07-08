# Local Kubernetes Learning Lab

This lab is for learning Kubernetes locally on the MacBook before touching the
future NixOS server.

It uses:

- OrbStack or Docker as the container runtime.
- kind as the local Kubernetes cluster.
- kubectl, helm, k9s, kustomize, kubeconform, stern, Flux, and Argo CD CLIs
  from the flake dev shell.

## Enter The Shell

```bash
nix develop .#kubernetes-learning
```

## Create The Cluster

```bash
kind create cluster --config labs/kubernetes/kind/cluster.yaml
kubectl cluster-info --context kind-learning
kubectl get nodes
```

The cluster maps:

- container port 80 to host port 8080
- container port 443 to host port 8443

## Install An Ingress Controller

Use ingress-nginx for the learning cluster:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

## Deploy The Sample App

```bash
kubectl apply -f labs/kubernetes/kind/manifests/whoami.yaml
kubectl get all -n learning
kubectl get ingress -n learning
```

Then open:

```text
http://whoami.localhost:8080
```

If DNS for `whoami.localhost` does not resolve on your machine, test with:

```bash
curl -H 'Host: whoami.localhost' http://127.0.0.1:8080
```

## Things To Practice

Start with these commands:

```bash
kubectl get pods -n learning
kubectl describe deployment whoami -n learning
kubectl logs -n learning -l app.kubernetes.io/name=whoami
kubectl scale deployment whoami -n learning --replicas=3
kubectl rollout status deployment/whoami -n learning
stern whoami -n learning
k9s
```

Validate manifests:

```bash
kubeconform -strict -summary labs/kubernetes/kind/manifests/whoami.yaml
```

## Delete The Lab

```bash
kind delete cluster --name learning
```

## Learning Order

1. Pod
2. Deployment
3. Service
4. Ingress
5. ConfigMap
6. Secret
7. PersistentVolumeClaim
8. Helm chart
9. Kustomize overlay
10. GitOps with Flux

Do not start with GitOps. Learn `kubectl apply`, `kubectl describe`, and
`kubectl logs` first.
