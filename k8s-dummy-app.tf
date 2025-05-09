

resource "kubernetes_deployment_v1" "demo_web" {
  metadata {
    name = "demo-web"
    labels = {
      app = "demo-web" # It's good practice to label deployments too
    }
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "demo-web"
      }
    }

    template {
      metadata {
        labels = {
          app = "demo-web"
        }
      }
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"

          port { # 'ports' is a list
            container_port = 80
          }
        }
      }
    }
  }
  depends_on = [
    helm_release.nginx_ingress
  ]
}

resource "kubernetes_service_v1" "demo_web" {
  metadata {
    name = "demo-web"
    labels = { # Optional: labels for the service itself
      app = "demo-web"
    }
  }
  spec {
    selector = {
      app = "demo-web" # Selects pods with this label
    }

    port {
      port        = 80 # Port the service is available on
      target_port = 80 # Port on the pods the service routes to
    }
  }
  depends_on = [
    kubernetes_deployment_v1.demo_web
  ]
}