resource "helm_release" "prometheus_stack" {
  name       = "prometheus"                                         # Name of the Helm release
  repository = "https://prometheus-community.github.io/helm-charts" # Helm repository URL
  chart      = "kube-prometheus-stack"                              # Chart name
  namespace  = "monitoring"                                         # Namespace to deploy into
  version    = "57.0.2"                                             # Specify a chart version for consistency (check for latest)

  create_namespace = true # Creates the namespace if it doesn't exist

  set {
    name  = "grafana.enabled" # Example: Ensure Grafana is enabled
    value = "true"
  }

  timeout = 600 # Timeout for Helm operations (in seconds)
}





resource "helm_release" "otel_collector" {
  name             = "opentelemetry-collector"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart            = "opentelemetry-collector"
  namespace        = "monitoring"
  version          = "0.93.0"
  create_namespace = true

  values = [
    <<-EOT
    mode: daemonset
    image:
      repository: otel/opentelemetry-collector-contrib
      tag: 0.93.0
    config:
      receivers:
        otlp:
          protocols:
            grpc:
              endpoint: 0.0.0.0:4317
            http:
              endpoint: 0.0.0.0:4318
        hostmetrics:
          collection_interval: 30s
          scrapers:
            cpu:
            memory:
            disk:
            network:
      processors:
        batch:
          timeout: 10s
      exporters:
        prometheus:
          endpoint: "0.0.0.0:8889"
      service:
        pipelines:
          metrics:
            receivers: [otlp, hostmetrics]
            processors: [batch]
            exporters: [prometheus]
    EOT
  ]

  depends_on = [
    helm_release.prometheus_stack
  ]
  timeout = 900
}
