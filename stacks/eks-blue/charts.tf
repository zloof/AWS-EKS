provider "helm" {
  version = "~> 1.3"
  kubernetes {
      host                   = data.aws_eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
      token                  = data.aws_eks_cluster_auth.cluster.token
      load_config_file       = false
  }
}

locals {
  namespace_ingress_nginx = "ingress-nginx"
}

# kubernetes-namespaces
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = local.namespace_ingress_nginx
  }
}

# helm-releases
resource "helm_release" "ingress-nginx" {
  name         = "ingress-nginx"
  repository   = "https://kubernetes.github.io/ingress-nginx"
  chart        = "ingress-nginx"
  version      = "2.15.0"
  namespace    = local.namespace_ingress_nginx
  force_update = true
  values = [<<VARIABLES
controller:
  stats:
    enabled: true
  metrics:
    enabled: true
  service:
    type: NodePort
    nodePorts:
      http: 30000
  resources:
    limits:
      cpu: 1
      memory: 2Gi
  replicaCount: 3
  minAvailable: 2
  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 100
    targetCPUUtilizationPercentage: 20
    targetMemoryUtilizationPercentage: null
  config:
    use-forwarded-headers: "true"
    http-redirect-code: "302"
    disable-access-log: "true"
  headers:
    X-Request-Start: t=$${msec}
defaultBackend:
  enabled: true
VARIABLES
]

}
