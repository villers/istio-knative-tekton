module "knative" {
  source = "./modules/knative"
  knative_version = var.knative_version
}