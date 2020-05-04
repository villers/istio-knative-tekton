resource "null_resource" "tekton_install" {
  triggers = {
    tekton_version = var.tekton_version
  }

  provisioner "local-exec" {
    command = <<-EOF
    kubectl apply --filename https://github.com/tektoncd/pipeline/releases/download/${self.triggers.tekton_version}/release.yaml
    sleep 10
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOF
    kubectl delete \
    --filename https://github.com/tektoncd/pipeline/releases/download/${self.triggers.tekton_version}/release.yaml
    exit 0
    EOF
    interpreter = ["/bin/sh", "-c"]
  }
}

resource "null_resource" "tekton_dashboard_install" {
  triggers = {
    tekton_dashboard_version = var.tekton_dashboard_version
  }

  provisioner "local-exec" {
    command = <<-EOF
    kubectl apply --filename https://github.com/tektoncd/dashboard/releases/download/${self.triggers.tekton_dashboard_version}/tekton-dashboard-release.yaml
    sleep 10
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOF
    kubectl delete \
    --filename https://github.com/tektoncd/dashboard/releases/download/${self.triggers.tekton_dashboard_version}/tekton-dashboard-release.yaml
    exit 0
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  depends_on = [null_resource.tekton_install]
}

