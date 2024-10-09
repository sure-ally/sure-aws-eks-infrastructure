# Service mesh compose of Istio base + Istiod 
# Istiod is combinations of -- Galley, Citadel, Pilot (old school)

# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install sure-istiod -n istio-system --create-namespace istio/istiod --set telemetry.enabled=true --set global.istioNamespace=istio-system
resource "helm_release" "sure_istiod" {
  name = "sure-istiod"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.23.2"

  set {
    name  = "telemetry.enabled"
    value = "true"
  }

  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }

  set {
    name  = "meshConfig.ingressService"
    value = "istio-gateway"
  }

  set {
    name  = "meshConfig.ingressSelector"
    value = "gateway"
  }

  depends_on = [helm_release.sure_istio_base]
}