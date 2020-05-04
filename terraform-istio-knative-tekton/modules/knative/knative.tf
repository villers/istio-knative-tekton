resource "null_resource" "knative_custom_resource_definitions" {
  triggers = {
    knative_version = var.knative_version
  }

  provisioner "local-exec" {
    command = <<-EOF
    kubectl apply --selector knative.dev/crd-install=true \
     --filename https://github.com/knative/serving/releases/download/${self.triggers.knative_version}/serving-crds.yaml
    sleep 10
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOF
    kubectl delete \
     --filename https://github.com/knative/serving/releases/download/${self.triggers.knative_version}/serving-crds.yaml
    exit 0
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  depends_on = [var.istio_lean_install]
}

resource "null_resource" "knative_install" {
  triggers = {
    knative_version = var.knative_version
  }

  provisioner "local-exec" {
    command = <<-EOF
      kubectl apply \
       --filename https://github.com/knative/serving/releases/download/${self.triggers.knative_version}/serving-core.yaml
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOF
    kubectl delete \
       --filename https://github.com/knative/serving/releases/download/${self.triggers.knative_version}/serving-core.yaml
      exit 0
    EOF
    interpreter = ["/bin/sh", "-c"]
  }
  depends_on = [null_resource.knative_custom_resource_definitions]
}

resource "null_resource" "knative_install_istio" {
  triggers = {
    knative_version = var.knative_version
  }

  provisioner "local-exec" {
    command = <<-EOF
      kubectl apply \
       --filename https://github.com/knative/net-istio/releases/download/${self.triggers.knative_version}/release.yaml
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOF
    kubectl delete \
       --filename https://github.com/knative/net-istio/releases/download/${self.triggers.knative_version}/release.yaml
      exit 0
    EOF
    interpreter = ["/bin/sh", "-c"]
  }
  depends_on = [null_resource.knative_install]
}

resource "null_resource" "knative_install_autoscalling" {
  triggers = {
    knative_version = var.knative_version
  }

  provisioner "local-exec" {
    command = <<-EOF
      kubectl apply \
       --filename https://github.com/knative/serving/releases/download/${self.triggers.knative_version}/serving-hpa.yaml
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOF
    kubectl delete \
       --filename https://github.com/knative/serving/releases/download/${self.triggers.knative_version}/serving-hpa.yaml
      exit 0
    EOF
    interpreter = ["/bin/sh", "-c"]
  }
  depends_on = [null_resource.knative_install_istio]
}

resource "null_resource" "knative_monitoring_install" {
  triggers = {
    knative_version = var.knative_version
  }

  provisioner "local-exec" {
    command = <<-EOF
      kubectl apply --filename https://github.com/knative/serving/releases/download/${self.triggers.knative_version}/monitoring-core.yaml
      kubectl apply \
       --filename https://github.com/knative/serving/releases/download/${self.triggers.knative_version}/monitoring-metrics-prometheus.yaml
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOF
      kubectl delete --filename https://github.com/knative/serving/releases/download/${self.triggers.knative_version}/monitoring-metrics-prometheus.yaml
      kubectl delete \
       --filename https://github.com/knative/serving/releases/download/${self.triggers.knative_version}/monitoring-core.yaml
      exit 0
    EOF
    interpreter = ["/bin/sh", "-c"]
  }
  depends_on = [null_resource.knative_install_autoscalling]
}

resource "null_resource" "knative_config_install" {
  triggers = {
    knative_version = var.knative_version
  }

  provisioner "local-exec" {
    command = <<-EOF
      kubectl apply -f ./modules/knative/config_domain.yaml
	  kubectl apply -f ./modules/knative/services.yaml
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOF
    kubectl delete \
      kubectl delete -f ./modules/knative/config_domain.yaml
	  kubectl delete -f ./modules/knative/services.yaml
      exit 0
    EOF
    interpreter = ["/bin/sh", "-c"]
  }
  depends_on = [null_resource.knative_monitoring_install]
}
