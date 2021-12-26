# DigitalOcean Gitops with ArgoCD & Tekton with Kaniko Challenge

Repo Created for [DigitalOcean Kubernetes Challenge](https://www.digitalocean.com/community/pages/kubernetes-challenge)


## Overview

I chose the Gitops challenge because it was something I have never tried before. I was sure that this particular exercise will push my boundaries and let me learn something new.

## Prepartion

Before the weeks of actually starting to work on the project I took a good amount of time learning about ArgoCD, Tekton and Kaniko. Before that week all of these were words/tools that I've never heard. I personally liked the idea of kaniko, building docker images on the fly(who knew I was gonna struggle with it so much later). 

## Setup

### Creating Flask App

I did not want to spend a lot of time creating the application. I have done it a million times before, I can do it again. For testing purposes all we need is a "hello world".

1. Created a basic flask app with hello world API
2. Added requirements.txt file
3. Added Dockerfile for running the app.

### Setting up Doctl

`doctl` is the Digitalocean command line tool, which came handy for setting up and configuring Docker registry and Kubernetes cluster. To initialize I used to PAT.

```
brew install doctl
```

### Setting up Kube cluster with terraform

Next step is to setup the kubernetes cluster with terraform. Again used Terraform instead of using `doctl` or UI because I have never tried it before and wanted to.
Quickly searched the internet and learned how to setup a cluster, create nodes and add them to a cluster, check `infra/provider.tf`.

```
terraform init
terraform plan
terraform apply
```

Although the setup was fairly straightforward I stumbled upon following errors

```
ERROR invalid version slug
```

Used the [Stackoverflow solution](https://stackoverflow.com/a/62730936/6340775) to find kubernetes versions supported by `doctl` and used the same. The error occurs because of a mismatch between kubernetes version supported by DO vs the one configured in Terraform


### Install Kubernetes CLI tools 

- `kubectl` is essential for playing aorund with cluster.
- `kns` comes handy to switch between name spaces
- `k9s` helps you playaround with cluster resources without typing a million command

```
brew install kubectl 
brew tap blendle/blendle
brew install kns
brew install k9s
```

### Setting up ArgoCD

As I started setting up ArgoCD the `Quay.io` docker registry was down, I had to wait until the following error wears off

```
rpc error: code = Unknown desc = failed to pull and unpack image "quay.io/argoproj/argocd:v2.2.1": failed to copy: httpReaderSeeker: failed open: unexpected status code https://quay.io/v2/argoproj/argocd/blobs/sha256:9e6a0d5477cff31ce49b4d3bc07409ebd27609574e968043d0b9c10acf854ebc: 502 Bad Gateway
```

Used the [ArgoCD setup commands](ci-cd/argocd/argo.sh) to create an ArgoCD deployment.


### Setting up Tekton

With respect to Tekton we need both `Pipelines` and `Triggers`. Triggers let's us listen to Github events to trigger a set of actions. Pipelines lets us create those series of actions and link them together. The [ci-cd/tekton.sh](ci-cd/tekton.sh) file contains the kubectl commands to set it up



## Setting up Ambassdor

This step is used to expose ArgoCD and webhook endpoint to the outside world via `EXTERNAL_IP`
1. First, I setup Ambassdor using [ci-cd/ambassador/ambassdor.sh](ci-cd/ambassador/ambassdor.sh) script.
2. Install certificate manager using [ci-cd/ambassador/certs.sh](ci-cd/ambassador/certs.sh) script
3. Setup a subdomain `do-challenge.thelearning.dev` and mapped it to the `EXTERNAL_IP`
4. Added [certificates](ci-cd/ambassador/certificates.yaml) and [tls](ci-cd/ambassador/tls.yaml) 

### Docker Registry

To push the Docker images we need a registry. I created a [Digitalocean Registry](https://www.digitalocean.com/products/container-registry/)


## Pipeline Design

We have all the required setup and up and running. Next step is to design Tekton Pipelines, link it to ArgoCD and use kaniko to build and push images.

### Secrets and Resources

```
kubectl apply -k tekton-pipeline/resources/.
```

### ArgoCD pipeline

We are going to setup 2 ArgoCD apps 

1. The Tekton pipeline
2. The Flask Application

Each of these folders have it's own `kustomize.yaml` file to setup the kubernetes resources


```

argocd login do-challenge.thelearning.dev --grpc-web-root-path /argo-cd
argocd cluster add do-ams3-terraform-do-cluster   
argocd app create tekton-pipeline-app --repo https://github.com/bhavaniravi/digitalocean-gitops.git --path tekton-pipeline --dest-server https://kubernetes.default.svc --dest-namespace tekton-argocd-example
argocd app create flask-app --repo https://github.com/bhavaniravi/digitalocean-gitops.git --path kube --dest-server https://kubernetes.default.svc --dest-namespace flask-app --sync-option CreateNamespace=true
```

### ArgoCD to Github

On pushing to Github ArgoCD syncs the kubernetes resources of tekton with kubernetes resources in the cluster.

### Tekton Pipelines

The two important parts of the trigger -> Build -> Deploy tekton pipeline

1. EventListener listents to the Github webhook
2. TriggerTemplate creates Pipeline based on custom input from TriggerBinding
3. Pipelines Task spin up a kaniko container building and pushing the images
4. Once image is pushed redeploys the flask app


### Create webhook in Github

Now that the event listeners and pipelines are ready, the next step is to add the webhook url to the **Github Repo**. You can do this under repo settings.

```
http://<cluster_url>/tekton-argocd-example-build-mapping/
```

> At this point anytime you push code to the repo, the tekton pipeline executed.

### Simulate push

You can also simulate the push webhook call with the following snippet.

```

curl -i \
  -H 'X-GitHub-Event: push' \
  -H 'Content-Type: application/json' \
  -d '{"ref":"refs/heads/main","head_commit":{"id":"123abc"}}' \
  https://do-challenge.thelearning.dev/tekton-argocd-example-build-mapping/
```
---

The write up is definitely a 300 feet overview, moving forward I'll be writing detailed blogs on each of these concepts in my [Devops-Deep-Dive Series Newsletter](https://www.getrevue.co/profile/bhavaniravi)