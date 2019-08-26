variable "cluster" {
  description = "Gcloud name of the cluster"
}

variable "zone" {
}

variable "project" {
}

output "token" {
  value = data.external.get_info.result["token"]
}

output "kube_config" {
  value = data.external.get_info.result["kube_config"]
}
