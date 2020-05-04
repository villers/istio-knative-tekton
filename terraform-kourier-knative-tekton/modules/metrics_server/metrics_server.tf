resource "helm_release" "metrics_server" {
  chart = "stable/metrics-server"
  name = "metrics-server"
  namespace = "kube-system"

  values = [
    <<-EOF
    args:
      - "--kubelet-insecure-tls"
    EOF
  ]
}