# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install sure-istio-gateway -n istio-ingress --create-namespace istio/gateway
resource "helm_release" "sure_istio_gateway" {
  name = "sure-istio-gateway"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  namespace        = "istio-ingress"
  create_namespace = true
  version          = "1.23.2"

  depends_on = [
    helm_release.sure_istio_base,
    helm_release.sure_istiod
  ]
}