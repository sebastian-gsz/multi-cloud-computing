variable "project_id" {
  description = "ID del proyecto de GCP"
  type        = string
}
variable "region" {
  default     = "us-west1"
}
variable "admin_user" {
  description = "Usuario que tiene permisos para suplantar (ej: user:admin@dominio.com)"
  type        = string
}