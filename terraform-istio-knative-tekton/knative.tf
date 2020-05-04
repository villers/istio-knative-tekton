module "knative" {
  source = "./modules/knative"
  knative_version = var.knative_version
  istio_lean_install = module.istio.istio_lean_install
}