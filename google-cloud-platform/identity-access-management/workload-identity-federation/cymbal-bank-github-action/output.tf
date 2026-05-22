output "sa_provisioner" {
  value = google_service_account.sa_provisioner.email
}
output "sa_vm" {
  value = google_service_account.sa_vm_final.email
}
output "provisioner_sa_email" {
  description = "Email de la cuenta de servicio que realiza la provisión"
  value       = google_service_account.sa_provisioner.email
}
output "vm_instance_name" {
  description = "Nombre de la instancia creada"
  value       = google_compute_instance.vm_test.name
}
output "vm_external_ip" {
  description = "IP pública de la instancia de prueba"
  value       = google_compute_instance.vm_test.network_interface[0].access_config[0].nat_ip
}
