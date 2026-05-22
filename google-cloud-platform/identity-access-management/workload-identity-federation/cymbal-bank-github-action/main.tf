resource "google_compute_instance" "vm_test" {
  provider     = google.impersonated
  name         = "vm-final-test"
  machine_type = "e2-micro"
  zone         = "${var.region}-c"
  boot_disk {
    initialize_params { image = "debian-cloud/debian-11" }
  }
  network_interface {
    network = "default"
    access_config {} 
  }
  service_account {
    email  = google_service_account.sa_vm_final.email
    scopes = ["cloud-platform"]
  }
  depends_on = [
      google_service_account_iam_member.allow_impersonation,
      google_service_account_iam_member.allow_impersonation_user,
      google_service_account.sa_vm_final,
      google_project_iam_member.bind_devops
  ]
}