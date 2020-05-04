provider "kubernetes" {
  version = "~> 1.11"
  config_context_cluster   = "docker-desktop"
}

provider "helm" {
  version = "~> 1.0"
}

provider "null" {
  version = "~> 2.0"
}