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
  depends_on = [null_resource.knative_install]
}

resource "null_resource" "knative_install_kourier" {
  triggers = {
    knative_version = var.knative_version
  }

  provisioner "local-exec" {
    command = <<-EOF
      kubectl apply \
       --filename https://github.com/knative/net-kourier/releases/download/${self.triggers.knative_version}/kourier.yaml
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOF
    kubectl delete \
       --filename https://github.com/knative/net-kourier/releases/download/${self.triggers.knative_version}/kourier.yaml
      exit 0
    EOF
    interpreter = ["/bin/sh", "-c"]
  }
  depends_on = [null_resource.knative_install]
}

resource "null_resource" "knative_config_install" {
  triggers = {
    knative_version = var.knative_version
  }

  provisioner "local-exec" {
    command = <<-EOF
      kubectl patch configmap/config-network -n knative-serving --type merge -p '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'
      kubectl patch configmap/config-domain -n knative-serving --type merge -p '{"data":{"127.0.0.1.nip.io":""}}'
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  depends_on = [null_resource.knative_install]
}
