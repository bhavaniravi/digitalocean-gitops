terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

variable dotoken {}

provider "digitalocean" {
  token   = "${var.dotoken}"
}

resource "digitalocean_kubernetes_cluster" "kubernetes_cluster" {
  name    = "terraform-do-cluster"
  region  = "ams3"
  version = "1.21.5-do.0"

  tags = ["my-tag"]

  # This default node pool is mandatory
  node_pool {
    name       = "default-pool"
    size       = "s-1vcpu-2gb" # minimum size, list available options with `doctl compute size list`
    auto_scale = false
    node_count = 1
    tags       = ["node-pool-tag"]
  }

}

# Another node pool for applications
resource "digitalocean_kubernetes_node_pool" "app_node_pool" {
  cluster_id = digitalocean_kubernetes_cluster.kubernetes_cluster.id

  name = "app-pool"
  size = "s-1vcpu-2gb"
  tags = ["applications"]

  # you can setup autoscaling
  auto_scale = true
  min_nodes  = 1
  max_nodes  = 2
}