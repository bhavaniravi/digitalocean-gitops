kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.2.1/manifests/install.yaml
kubectl -n argocd port-forward svc/argocd-server -n argocd 8080:443

kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$10$LN7KOOaU1xdhk1vQpzOFUOKPpgxK84Q6o6Ik0DGHLKfbGSZae.nE6",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'