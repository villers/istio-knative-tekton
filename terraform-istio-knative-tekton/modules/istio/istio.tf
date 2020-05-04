resource "null_resource" "istio_source" {
  triggers = {
    istio_version = var.istio_version
  }

  provisioner "local-exec" {
    command = <<-EOF
      export ISTIO_VERSION=${self.triggers.istio_version}
      if [ ! -d istio-${self.triggers.istio_version} ]; then
        curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${self.triggers.istio_version} sh -
      fi
    EOF
    working_dir = "./k8s"
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    when = destroy
    command = "rm -rf ./k8s/istio-${self.triggers.istio_version}"
    interpreter = ["/bin/sh", "-c"]
  }
}

resource "null_resource" "istio_lean_install" {
  triggers = {
    istio_version = var.istio_version
  }

  provisioner "local-exec" {
    command = <<-EOF
    ./k8s/istio-${self.triggers.istio_version}/bin/istioctl manifest apply --set profile=demo -f ./modules/istio/profile.yaml
    kubectl apply -f ./modules/istio/services.yaml
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOF
      kubectl delete -f ./modules/istio/services.yaml
      ./k8s/istio-${self.triggers.istio_version}/bin/istioctl manifest generate --set profile=demo -f ./modules/istio/profile.yaml | kubectl delete -f -
      exit 0
    EOF
    interpreter = ["/bin/sh", "-c"]
  }

  depends_on = [null_resource.istio_source]
}
