kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.0.0/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io && helm repo update
kubectl create ns cert-manager
helm install cert-manager --namespace cert-manager jetstack/cert-manager

