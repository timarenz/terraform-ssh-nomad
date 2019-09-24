output "id" {
  description = "Output variable to be used for other resources to depend on this module"
  value       = null_resource.complete.id
}

output "nomad_config" {
  description = "nomad configuration in HCL format"
  value       = local.config_file
}
