# Lab 01 — Azure Governance & Resource Management

## 1. Overview & Architecture

This lab implements a Terraform-managed Azure governance foundation with separate development and production environments, group-based access control, subscription-level deployment restrictions, and production deletion protection.

The environment was initially configured and tested manually in Azure Portal, then rebuilt using Terraform to demonstrate repeatable infrastructure provisioning and teardown.

### Architecture

```text
Azure Subscription
│
├── Azure Policy: Allowed Locations
│   ├── Scope: Subscription
│   ├── Allowed: eastus, eastus2, global
│   └── Effect: Deny
│
├── rg-cloudlab-dev
│   ├── Cloud-Admin       → Owner
│   ├── Cloud-Engineers   → Contributor
│   ├── Developers        → Contributor
│   └── Auditors          → Reader
│
└── rg-cloudlab-prod
    ├── Cloud-Admin       → Owner
    ├── Cloud-Engineers   → Contributor
    ├── Auditors          → Reader
    └── AccidentalDeleteLock → CanNotDelete
```

The Azure subscription and Microsoft Entra ID groups already exist. Terraform references them through data sources rather than managing their lifecycle.

## 2. Governance Design

### Resource Organization

| Resource Group     | Region  | Environment |
| ------------------ | ------- | ----------- |
| `rg-cloudlab-dev`  | East US | Development |
| `rg-cloudlab-prod` | East US | Production  |

Both resource groups use `environment`, `owner`, and `application` tags for organization.

### Role-Based Access Control

Access is assigned to Microsoft Entra ID security groups at resource-group scope.

| Group           | Development | Production           |
| --------------- | ----------- | -------------------- |
| Cloud-Admin     | Owner       | Owner                |
| Cloud-Engineers | Contributor | Contributor          |
| Developers      | Contributor | No direct assignment |
| Auditors        | Reader      | Reader               |

Developers receive write access to development but no direct production assignment. Auditors receive read-only access to both environments.

Higher-scope permissions may still be inherited, so the matrix represents the Terraform-managed assignments rather than every user's effective permissions.

### Azure Policy

A custom policy definition, `east-region-lock`, restricts deployment locations to `eastus`, `eastus2`, and `global`.

The policy uses:

- **Mode:** `All`
- **Effect:** `Deny`
- **Assignment:** `subscription-region-lock`
- **Scope:** Azure subscription

The subscription-level assignment applies the restriction across development, production, and other resources within the subscription.

### Production Protection

The `AccidentalDeleteLock` management lock uses `CanNotDelete` at the production resource-group scope.

It blocks deletion of the protected resource group and its resources while permitting ordinary modifications. Development remains unlocked for easier experimentation and teardown.

## 3. Terraform Implementation

Terraform uses the AzureRM and AzureAD providers to manage governance resources and reference existing identities.

### Managed Resources

| Resource                       |  Count |
| ------------------------------ | -----: |
| Resource groups                |      2 |
| RBAC role assignments          |      7 |
| Custom policy definition       |      1 |
| Subscription policy assignment |      1 |
| Management lock                |      1 |
| **Total**                      | **12** |

### Existing Resources Referenced

Five data sources retrieve the current Azure subscription and four existing Entra ID groups: Cloud-Admin, Cloud-Engineers, Developers, and Auditors.

### Configuration Files

| File                       | Purpose                                                  |
| -------------------------- | -------------------------------------------------------- |
| `main.tf`                  | Resource groups, RBAC, Azure Policy, management lock     |
| `providers.tf`             | Terraform version constraints and provider configuration |
| `variables.tf`             | Input variables                                          |
| `terraform.tfvars.example` | Example local variable configuration                     |
| `.terraform.lock.hcl`      | Locked provider selections and checksums                 |

Terraform resource references establish dependencies, including RBAC assignments depending on their resource groups and the policy assignment depending on its definition.

## 4. Deployment & Cleanup

### Prerequisites

- Terraform and Azure CLI installed
- Authenticated Azure session with the required governance permissions
- Existing Azure subscription and four Entra ID security groups
- AzureRM and AzureAD provider authentication configured

From `labs/01-governance/`, create a local `terraform.tfvars` using `terraform.tfvars.example` as a reference. The configuration requires a tenant ID.

### Deploy

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Review the plan before applying. A deployment from an empty Terraform state is expected to create 12 managed resources.

### Destroy

```bash
terraform plan -destroy
terraform destroy
```

Review the destruction plan before approving. Terraform should remove the production management lock before deleting its protected resource group.

The existing Entra groups, subscription, budget, and unrelated policy initiatives are not managed by this configuration and should remain intact.

## 5. Validation & Results

The environment was validated through Terraform state inspection and Azure Portal testing.

| Validation                                                    | Result |
| ------------------------------------------------------------- | ------ |
| Development and production resource groups created in East US | Passed |
| Seven RBAC assignments match the access matrix                | Passed |
| Custom policy definition and subscription assignment verified | Passed |
| West US deployment blocked by policy                          | Passed |
| East US 2 deployment permitted                                | Passed |
| Production resource-group deletion blocked by lock            | Passed |
| Development resource group has no lock                        | Passed |
| Terraform state tracks 12 managed resources                   | Passed |

The deployment and functional tests confirmed the intended governance behavior.

**Cleanup verification:** Pending final confirmation that Terraform-managed resources have been removed and pre-existing subscription resources remain unaffected.

## 6. Engineering Decisions & Tradeoffs

**Group-based RBAC:** Permissions are assigned to Entra groups rather than individual users, simplifying access management. The design separates development and production responsibilities, although inherited permissions require separate consideration.

**Subscription-level policy:** A single assignment enforces regional governance across environments. This provides centralized control but also affects unrelated resources in the subscription.

**Policy mode `All`:** Chosen to include resource groups in policy evaluation. The broad location condition may require refinement for resource types without standard location properties.
Reference: [Azure Policy definition structure basics (Resource Manager modes)](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure-basics#mode)

**Production-only lock:** Production receives deletion protection while development remains flexible. The lock is an operational safeguard, not an absolute security boundary.

**Existing-resource data sources:** Terraform references the subscription and Entra groups without owning their lifecycle, avoiding unintended deletion of shared resources.

**Local Terraform state:** Sufficient for this individual learning lab. A shared engineering environment would benefit from remote state storage, state locking, controlled access, and CI/CD-based deployment.

**Future improvements:** Parameterized policy rules, more granular RBAC, automated policy tests, remote state, and reusable Terraform modules.

---

This lab establishes the governance foundation for the broader Azure Cloud Lab, where subsequent labs introduce storage, networking, compute, monitoring, and infrastructure automation.
