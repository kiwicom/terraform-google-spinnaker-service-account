resource "kubernetes_service_account" "spinnaker" {
  metadata {
    name      = "spinnaker-service-account"
    namespace = "kube-system"
  }

  provisioner "local-exec" {
    command = <<EOF
gcloud container clusters get-credentials ${var.cluster} --zone ${var.zone} --project ${var.project}
cat <<KOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: spinnaker-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: spinnaker-service-account
  namespace: kube-system
KOF
EOF
  }
}

data "external" "get_info" {
  program = ["bash", "${path.module}/get-info.sh"]

  query = {
    service_account_token_name = kubernetes_service_account.spinnaker.default_secret_name
    cluster                    = var.cluster
    zone                       = var.zone
    project                    = var.project
  }
}
