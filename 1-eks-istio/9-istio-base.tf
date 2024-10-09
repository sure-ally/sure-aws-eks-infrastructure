# Service mesh compose of Istio base + Istiod 
# Istio base  -- 
# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install sure-istio-base-release -n istio-system --create-namespace istio/base --set global.istioNamespace=istio-system
resource "helm_release" "sure_istio_base" {
  name = "sure-istio-base"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.23.2" # Search charts/base https://istio-release.storage.googleapis.com/

  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }
}