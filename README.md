# Digital Ocean Gitops

Repo Created for [DigitalOcean Kubernetes Challenge](https://www.digitalocean.com/community/pages/kubernetes-challenge)

## Setup

### Creating Flask App

1. Created a basic flask app with hello world API
2. Added requirements.txt file
3. Added Dockerfile for running the app

### Setting up Doctl

```
brew install doctl
```

### Setting up Kube cluster with terraform

check infra/provider.tf

```
terraform init
terraform plan
terraform apply
```


ERROR invalid version slug

ERROR :: validation error: worker_node_pool_specs[0].invalid label padok.fr/en/blog=up

### Setting up loadbalancer

```
resource "digitalocean_loadbalancer" "ingress_load_balancer" {
  name   = digitalocean_kubernetes_cluster.kubernetes_cluster.id
  region = "ams3"
  size = "lb-small"
  algorithm = "round_robin"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"

  }

  lifecycle {
      ignore_changes = [
        forwarding_rule,
    ]
  }

}
```


### Install Kns

```
brew tap blendle/blendle
brew install kns
```

### Setting up ArgoCD


rpc error: code = Unknown desc = failed to pull and unpack image "quay.io/argoproj/argocd:v2.2.1": failed to copy: httpReaderSeeker: failed open: unexpected status code https://quay.io/v2/argoproj/argocd/blobs/sha256:9e6a0d5477cff31ce49b4d3bc07409ebd27609574e968043d0b9c10acf854ebc: 502 Bad Gateway

The public quay.io is down

### Setting up Tekton

kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.16.0/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/previous/v0.8.1/release.yaml

## Setting up Ambassdor

AMBASSADOR_IP=$(kubectl get -n ambassador service ambassador -o "go-template={{range .status.loadBalancer.ingress}}{{or .ip .hostname}}{{end}}")

## Registry

For registry used a DO registry

username: email
password: PAT automatically created

## ArgoCD pipeline

argocd app create tekton-pipeline-app --repo https://github.com/bhavaniravi/tekton-pipeline-example-pipeline.git --path tekton-pipeline --dest-server https://kubernetes.default.svc --dest-namespace tekton-argocd-example
argocd app create flask-app --repo https://github.com/bhavaniravi/digitalocean-gitops.git --path kube --dest-server https://kubernetes.default.svc --dest-namespace flask-app --sync-option CreateNamespace=true

## Create webhook in Github


## Simulate push

```

curl -i \
  -H 'X-GitHub-Event: push' \
  -H 'Content-Type: application/json' \
  -d '{"ref":"refs/heads/main","head_commit":{"id":"123abc"}}' \
  https://do-challenge.thelearning.dev/tekton-argocd-example-build-mapping/
```