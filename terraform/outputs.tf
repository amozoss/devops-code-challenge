output "service_url" {
  description = "The URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.hello_world.uri
}

output "repository_url" {
  description = "The URL of the Artifact Registry repository"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.hello_world.name}"
}
