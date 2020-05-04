module "tekton" {
  source = "./modules/tekton"
  tekton_version = var.tekton_version
  tekton_dashboard_version = var.tekton_dashboard_version
}