# Hello World App

A simple Node.js application that returns "Hello world" when accessed. This project demonstrates containerization with Docker, infrastructure as code with Terraform, and CI/CD with GitHub Actions on Google Cloud Platform.

## Features

- Simple Express.js server returning "Hello world"
- Dockerized application
- Terraform infrastructure for GCP deployment
- GitHub Actions CI/CD pipeline
- Deployed on Google Cloud Run

## Local Development

### Prerequisites

- Node.js 18+
- Docker
- Docker Compose

### Running Locally

1. Install dependencies:

   ```bash
   npm install
   ```

2. Run the application:

   ```bash
   npm start
   ```

3. Access the application at `http://localhost:8080`

### Running with Docker

1. Build and run with Docker Compose:

   ```bash
   docker-compose up --build
   ```

2. Access the application at `http://localhost:8080`

## GCP Deployment

### Prerequisites

- Google Cloud CLI installed and configured
- Terraform installed
- A GCP project created

### Manual Setup

1. Create a new GCP project:

   ```bash
   gcloud projects create YOUR_PROJECT_ID
   gcloud config set project YOUR_PROJECT_ID
   ```

2. Enable billing for your project in the GCP Console

3. Set up authentication:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

### Deploy with Terraform

1. Navigate to the terraform directory:

   ```bash
   cd terraform
   ```

2. Copy the example variables file:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars` with your project details:

   ```hcl
   project_id = "your-gcp-project-id"
   region     = "us-central1"
   ```

4. Initialize and apply Terraform:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. Note the service URL from the output

### Manual Docker Deployment

If you prefer to deploy manually without Terraform:

1. Build and push the Docker image:

   ```bash
   # Configure Docker for Artifact Registry
   gcloud auth configure-docker us-central1-docker.pkg.dev

   # Build the image
   docker build -t us-central1-docker.pkg.dev/dev-ops-code-challenge/hello-world-repo/hello-world:latest .

   # Push the image
   docker push us-central1-docker.pkg.dev/dev-ops-code-challenge/hello-world-repo/hello-world:latest
   ```

2. Deploy to Cloud Run:
   ```bash
   gcloud run deploy hello-world-app \
     --image us-central1-docker.pkg.dev/dev-ops-code-challenge/hello-world-repo/hello-world:latest \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated \
     --port 8080
   ```

## GitHub Actions CI/CD

### Setup

1. Fork or create a new repository for this project

2. Set up the following secrets in your GitHub repository:

   - `GCP_PROJECT_ID`: Your GCP project ID
   - `GCP_SA_KEY`: Service account key JSON (see below)

3. Create a service account for GitHub Actions:

   ```bash
   # Create service account
   gcloud iam service-accounts create github-actions \
     --display-name="GitHub Actions Service Account"

   # Grant necessary permissions
   gcloud projects add-iam-policy-binding dev-ops-code-challenge \
     --member="serviceAccount:github-actions@dev-ops-code-challenge.iam.gserviceaccount.com" \
     --role="roles/run.admin"

   gcloud projects add-iam-policy-binding dev-ops-code-challenge \
     --member="serviceAccount:github-actions@dev-ops-code-challenge.iam.gserviceaccount.com" \
     --role="roles/storage.admin"

   gcloud projects add-iam-policy-binding dev-ops-code-challenge \
     --member="serviceAccount:github-actions@dev-ops-code-challenge.iam.gserviceaccount.com" \
     --role="roles/artifactregistry.admin"

   gcloud projects add-iam-policy-binding dev-ops-code-challenge \
     --member="serviceAccount:github-actions@dev-ops-code-challenge.iam.gserviceaccount.com" \
     --role="roles/editor"

   gcloud projects add-iam-policy-binding dev-ops-code-challenge \
     --member="serviceAccount:github-actions@dev-ops-code-challenge.iam.gserviceaccount.com" \
     --role="roles/storage.admin"

   # Create and download key
   gcloud iam service-accounts keys create key.json \
     --iam-account=github-actions@dev-ops-code-challenge.iam.gserviceaccount.com
   ```

4. Copy the contents of `key.json` and add it as the `GCP_SA_KEY` secret in GitHub

5. Push your code to the main branch to trigger the deployment

### Workflow

The GitHub Actions workflow will:

1. Run tests (currently just a placeholder)
2. Build the Docker image with the correct platform (linux/amd64)
3. Push to Google Artifact Registry
4. Initialize and run Terraform to deploy infrastructure
5. Deploy the application to Cloud Run using Terraform
6. Make the service publicly accessible

## Project Structure

```
.
├── server.js                 # Main application file
├── package.json              # Node.js dependencies
├── Dockerfile                # Docker configuration
├── docker-compose.yml        # Docker Compose configuration
├── .dockerignore             # Docker ignore file
├── .github/
│   └── workflows/
│       └── deploy.yml        # GitHub Actions workflow
├── terraform/
│   ├── main.tf               # Main Terraform configuration
│   ├── variables.tf          # Terraform variables
│   ├── outputs.tf            # Terraform outputs
│   └── terraform.tfvars.example # Example variables file
└── README.md                 # This file
```

## API Endpoints

- `GET /` - Returns "Hello world"
- `GET /health` - Health check endpoint

## Cleanup

To remove all resources:

1. Delete the Cloud Run service:

   ```bash
   gcloud run services delete hello-world-app --region=us-central1
   ```

2. If using Terraform:

   ```bash
   cd terraform
   terraform destroy
   ```

3. Delete the service account:
   ```bash
   gcloud iam service-accounts delete github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com
   ```

## Troubleshooting

- Ensure your GCP project has billing enabled
- Check that all required APIs are enabled
- Verify service account permissions
- Check Cloud Run logs for application issues
- Ensure Docker images are pushed successfully to Artifact Registry
