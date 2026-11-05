# Azure Cloud Lab

A hands-on Azure cloud engineering project focused on building and automating secure, production-inspired cloud infrastructure.

## Overview

This project combines Azure infrastructure, networking, governance, security, and automation to build a reusable, Git-driven platform capable of deploying and operating a real application.

Development follows a **manual deployment → validation → Terraform automation** approach, with individual labs eventually integrated into a complete infrastructure platform.

## Technologies

- **Cloud:** Microsoft Azure
- **Infrastructure as Code:** Terraform
- **Automation:** Python, PowerShell, Azure CLI
- **Application:** Docker, FastAPI, Azure Container Apps
- **CI/CD:** GitHub Actions (planned)
- **Monitoring:** Azure Monitor, Log Analytics (planned)

## Labs

| Lab | Focus                                                            | Status      |
| --- | ---------------------------------------------------------------- | ----------- |
| 01  | [Governance & Resource Management](labs/01-governance/README.md) | Completed   |
| 02  | [Azure Storage](labs/02-storage/README.md)                       | Completed   |
| 03  | Azure Networking                                                 | In Progress |
| 04  | Azure Compute                                                    | Planned     |
| 05  | Monitoring & Observability                                       | Planned     |

## Current Progress

**Lab 03 — Azure Networking**

- [ ] Manual networking deployment and configuration
- [ ] Network security and connectivity validation
- [ ] Terraform networking implementation
- [ ] Final validation
- [ ] Documentation, commit, and cleanup

## End Goal

Deploy a secure Azure application environment using reusable Terraform modules, automated CI/CD pipelines, infrastructure monitoring, and Python/PowerShell automation.

- Integrate individual labs into a complete Azure infrastructure platform.
- Create an overall infrastructure architecture diagram.
- Implement reusable Terraform modules and automated deployment workflows.
