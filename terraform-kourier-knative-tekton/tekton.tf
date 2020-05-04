module "tekton" {
  source = "./modules/tekton"
  tekton_version = var.tekton_version
  tekton_dashboard_version = var.tekton_dashboard_version
  knative_config_install = module.knative.knative_config_install
}