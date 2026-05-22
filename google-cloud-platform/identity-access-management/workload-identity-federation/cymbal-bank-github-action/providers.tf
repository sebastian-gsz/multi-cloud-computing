provider "google" {
  project = var.project_id
  region  = var.region
}
provider "google" {
  alias                       = "impersonated"
  project                     = var.project_id
  impersonate_service_account = "sa-compute-terraform@${var.project_id}.iam.gserviceaccount.com"
}
