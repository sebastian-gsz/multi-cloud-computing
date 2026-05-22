# Se declaran las SA
resource "google_service_account" "sa_provisioner" {
  account_id   = "sa-compute-terraform"
  display_name = "Compute Engine Provisioner"
}
resource "google_service_account" "sa_vm_final" {
  account_id   = "sa-vm-final"
  display_name = "VM Final Identity"
} 
# Asignar rol DevOps (Preexistente)
resource "google_project_iam_member" "bind_devops" {
  project = var.project_id
  role    = "projects/${var.project_id}/roles/devops"
  member  = "serviceAccount:${google_service_account.sa_provisioner.email}"
}
# Asignar el rol "Service Account Admin" al nivel de proyecto
resource "google_project_iam_member" "sa_admin" {
  project = var.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_service_account.sa_provisioner.email}"
}
# 3. Permisos de suplantación
resource "google_service_account_iam_member" "allow_impersonation" {
  service_account_id = google_service_account.sa_provisioner.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = var.admin_user
} 
resource "google_service_account_iam_member" "allow_impersonation_user" {
  service_account_id = google_service_account.sa_provisioner.name
  role               = "roles/iam.serviceAccountUser"
  member             = var.admin_user
}
resource "google_service_account_iam_member" "sa_compute_user_on_vm_final" {
  service_account_id = google_service_account.sa_vm_final.name # Cuenta de destino a la que se le otorgan permisos
  role               = "roles/iam.serviceAccountUser"         # El rol necesario para impersonar
  member             = "serviceAccount:${google_service_account.sa_provisioner.email}" # Cuenta que recibe el permiso
}