resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.7.1" # Specify exact version namespace = "ingress-nginx" create_namespace = true
  depends_on = [aws_eks_cluster.eks, aws_eks_node_group.nodes]

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.ingressClassResource.name"
    value = "nginx"
  }
}



# # Example of another chart installation
# resource "helm_release" "prometheus" {
#   name             = "prometheus"
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   chart            = "prometheus"
#   namespace        = "monitoring"
#   create_namespace = true
# }
