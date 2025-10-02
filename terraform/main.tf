terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "dev-ops-code-challenge-terraform-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "cloud_run_api" {
  service = "run.googleapis.com"
}

resource "google_project_service" "cloud_build_api" {
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "container_registry_api" {
  service = "containerregistry.googleapis.com"
}

resource "google_project_service" "storage_api" {
  service = "storage.googleapis.com"
}

# Data source for existing GCS bucket for Terraform state
data "google_storage_bucket" "terraform_state" {
  name = "dev-ops-code-challenge-terraform-state"
}

# Cloud Run service
resource "google_cloud_run_v2_service" "hello_world" {
  name     = "hello-world-app"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.hello_world.name}/hello-world:${var.image_tag}"

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
  }

  depends_on = [
    google_project_service.cloud_run_api
  ]
}

# IAM policy to allow unauthenticated access
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.hello_world.location
  name     = google_cloud_run_v2_service.hello_world.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Artifact Registry repository for Docker images
resource "google_artifact_registry_repository" "hello_world" {
  location      = var.region
  repository_id = "hello-world-repo"
  description   = "Repository for Hello World app Docker images"
  format        = "DOCKER"

  depends_on = [
    google_project_service.container_registry_api
  ]
}
