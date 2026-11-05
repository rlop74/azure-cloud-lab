# Lab 02 — Azure Blob Storage with Terraform

## Overview

Provisioned and configured Azure Blob Storage using Terraform, focusing on secure authentication, data protection, lifecycle management, and least-privilege access control.

**Technologies:** Azure Storage, Terraform, Microsoft Entra ID, Azure RBAC, Azure CLI.

## Infrastructure

Five Terraform-managed resources:

| Resource         | Configuration                              |
| ---------------- | ------------------------------------------ |
| Resource Group   | `demoStorage` — East US                    |
| Storage Account  | `dudongstorage` — StorageV2, Standard, LRS |
| Blob Container   | `test` — Private                           |
| Lifecycle Policy | `rule1` — Targets `test/logs/`             |
| RBAC Assignment  | Storage Blob Data Reader — Container scope |

LRS was selected for a cost-conscious lab environment. The `logs/` directory is virtual and appears when blobs are uploaded with names such as `logs/application.log`.

## Security & Data Protection

| Configuration         | Implementation                                                          |
| --------------------- | ----------------------------------------------------------------------- |
| Authentication        | Entra ID for supported provider storage operations; Shared Key disabled |
| Anonymous Blob Access | Disabled at storage account level                                       |
| Transport Security    | HTTPS required; TLS 1.2 minimum                                         |
| Local Users / SFTP    | Disabled                                                                |
| Public Network Access | Enabled for lab testing                                                 |
| Blob Soft Delete      | 7 days                                                                  |
| Container Soft Delete | 7 days                                                                  |
| Blob Versioning       | Enabled                                                                 |
| Azure RBAC            | Storage Blob Data Reader assigned at container scope                    |

The AzureRM provider uses `storage_use_azuread = true`. Public network access remains enabled; private connectivity is outside this lab's scope.

### Lifecycle Management

Policy `rule1` applies to block blobs matching `test/logs/`.

| Object            | 30 days      | 90 days      | 365 days |
| ----------------- | ------------ | ------------ | -------- |
| Base blobs        | Cool tier    | Archive tier | Delete   |
| Snapshots         | Archive tier | Delete       | —        |
| Previous versions | —            | Delete       | —        |

Lifecycle actions execute asynchronously. The policy can be deployed before matching blobs exist.

## Deployment

**Prerequisites:** Azure subscription, Azure CLI, Terraform 1.5+, AzureRM 4.x, and appropriate Azure permissions.

```bash
az login
az account set --subscription "<subscription-id>"

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Create a local `terraform.tfvars` containing:

```hcl
rlopez_object_id = "<entra-user-object-id>"
```

The resource group location defaults to `eastus`.

**Note:** Terraform state, `.terraform/`, and `terraform.tfvars` are excluded from Git. The provider lock file is committed.

## Validation

Verified the deployed storage account configuration in the Azure portal, including HTTPS, TLS, anonymous access restrictions, Shared Key restrictions, soft delete, and versioning.

Additional validation commands:

```bash
# Verify Terraform-managed resources
terraform state list

# Check for configuration drift
terraform plan

# Test Entra-authenticated Blob read access
az storage blob list \
  --account-name dudongstorage \
  --container-name test \
  --auth-mode login \
  --output table
```

The Blob listing requires appropriate data-plane RBAC. Uploading test blobs requires additional write permissions.

## Key Learnings

- **Management plane vs. data plane:** Subscription Owner permissions allow resource management but do not automatically grant Entra-authenticated Blob data access.
- **Entra authentication:** Disabling Shared Key authorization requires compatible authentication methods for storage operations.
- **Least privilege:** Container-scoped RBAC limits the scope of Blob data access.
- **Virtual directories:** Blob paths such as `logs/application.log` create a directory-like structure without a separate directory resource.
- **Data protection:** Soft delete, versioning, and lifecycle management address different retention and recovery requirements.

## Cleanup

```bash
terraform destroy
```

Destroying the resource group removes the lab infrastructure and its data. Confirm no resources or data need to be retained before cleanup.
