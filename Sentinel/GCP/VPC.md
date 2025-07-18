
# 📘 How-To: Collect GCP VPC Flow Logs in Microsoft Sentinel

## 1. Overview
Google Cloud Platform (GCP) VPC Flow Logs capture metadata about network traffic in your Virtual Private Cloud (VPC). Microsoft Sentinel can ingest these logs for security monitoring and analytics using a push-based architecture.

---

## 2. Pre-Requisites
- A GCP project with VPC Flow Logs enabled.
- A GCP service account with appropriate permissions.
- A Pub/Sub topic and subscription for log export.
- A Microsoft Sentinel workspace.
- Terraform or manual setup capabilities.

---

## 3. Step-by-Step Setup

### 🔧 A. Enable VPC Flow Logs in GCP
- Enable flow logs at the subnet or project level using the Compute Engine API or Network Management API.
- Required roles:
  - `roles/compute.networkAdmin` or `roles/compute.admin`
  - `roles/networkmanagement.admin`
- Reference: [GCP VPC Flow Logs Documentation](https://cloud.google.com/vpc/docs/using-flow-logs)

### 🛠️ B. Set Up Log Export
- Create a **sink** to export logs to a **Pub/Sub topic**.
- Use Terraform or gcloud CLI to define:
  - `google_logging_project_sink`
  - `google_pubsub_topic`
  - `google_pubsub_subscription`
- Ensure the sink has permission to publish to the topic.

### 🧩 C. Connect to Microsoft Sentinel
- Follow the [Microsoft Sentinel GCP connector guide](https://learn.microsoft.com/en-us/azure/sentinel/connect-google-cloud-platform?tabs=terraform%2Cauditlogs#gcp-authentication-setup).
- Deploy the Terraform module from the [Azure Sentinel GitHub repository](https://github.com/Azure/Azure-Sentinel/blob/master/DataConnectors/GCP/Terraform/sentinel_resources_creation/GCPVPCFlowLogsSetup/readme.md).
- Configure:
  - GCP service account credentials.
  - Pub/Sub subscription.
  - Log type (e.g., `vpc_flows`).

---

## ⚠️ Gotchas and Lessons Learned

### 1. Terraform Errors
- If the Pub/Sub topic isn’t created before the subscription, you’ll get a `404: Resource not found` error.
- If the sink already exists, Terraform will throw a `409: alreadyExists` error. Use `terraform import` to manage existing resources.

### 2. IAM Permissions
- Ensure the service account used by the sink has `roles/pubsub.publisher` on the topic.
- The Sentinel connector service account must have `roles/pubsub.subscriber` on the subscription.

### 3. Geo Restrictions
- No geo restrictions were found when moving flow logs between regions (e.g., EU to US), but always validate with your compliance team.

### 4. On-Demand Ingestion
- For cost efficiency, consider using Azure Functions or Logic Apps to pull logs on demand based on CERT requests.

### 5. Centralized Storage
- Use centralized BLOB storage for logs before ingestion to simplify access and auditing.

### 6. Connector Availability
- As of July 2025, the GCP VPC Flow Logs connector is Generally Available in Sentinel.

---

## 📎 Supporting Resources
- Azure Monitor vs GCP – Comparison of logging capabilities.
- One Log API – Deep dive into GCP Stackdriver and log ingestion architecture.
- Sentinel Connector Enablement Guide – Covers DCR, DCE, and custom log ingestion strategies.

<img width="1105" height="636" alt="generated_image (1)" src="https://github.com/user-attachments/assets/d9a22108-577c-4af8-ba77-043ca54298df" />
