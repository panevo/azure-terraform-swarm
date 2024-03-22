# Terraform Azure Cluster with Docker Swarm

## Overview

This repository contains Terraform code to deploy a cluster of virtual machines in Microsoft Azure with Docker Swarm fully configured. The machines are automatically provisioned using cloud-init. Each machine gets its own data disk, and file sharing is provided by mounting an Azure Storage File Share. The number of manager and worker nodes is configurable, and a basic Python server is started on the first manager node to share the Swarm join token with other nodes.

This is a modern take of the approach proposed by Rui Carmo at: <https://github.com/rcarmo/azure-docker-swarm-cluster>

## Architecture

The Terraform configuration deploys the following resources in Azure:

- A resource group to contain all resources.
- A virtual network with a subnet for the all the virtual machines.
- A configurable number of virtual machines for the Docker Swarm cluster:
  - Manager nodes with a public IP address and a data disk.
  - Worker nodes with a data disk.
- Two network security groups with rules, one for the manager nodes and one for the worker nodes.
- A storage account with a file share, mounted on all the VMs.
- A load balancer to forward traffic to the virtual machines.

The Terraform configuration uses cloud-init to configure the virtual machines with Docker and Docker Swarm. The first manager node starts a Python server to share the join token with other nodes. The join token is retrieved by the other nodes using a simple HTTP request.

## Limitations

- In production, you may want to consider the use of an Azure Load Balancer to provide TLS termination
- The join token is shared in plain text over HTTP. In production, you should use a secure method to share the token.
- The configuration does not include monitoring, logging, or backup solutions. You should consider adding these services to your deployment.
- The load balancer is configured to forward traffic to any node in the cluster. On a larger cluster, you may want to configure the load balancer to forward traffic to worker nodes only. On a small cluster (<= 5 machines), you are likely to only have manager nodes so this cannot be avoided.

## Prerequisites

Before using this Terraform configuration, ensure you have the following prerequisites:

1. Azure subscription with the necessary permissions to create resources.
2. Terraform installed on your local machine. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).
3. Azure CLI installed for authentication and managing Azure resources. You can install it from [Azure CLI Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

Note that in production, you should configure a remote storage backend for Terraform state files to ensure consistency and collaboration among team members, as described in the [Azure documentation](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli).

For simplicity, this guide also connects to Azure using the Azure CLI. You can also use a service principal or managed identity for authentication.

## Usage

Follow these steps to deploy the Azure cluster with Docker Swarm:

1. Clone this repository to your local machine.

```bash
git clone https://github.com/panevo/azure-terraform-swarm.git
cd terraform-azure-docker-swarm
```

2. Generate a SSH key pair to use for accessing the VMs in the cluster.

```bash
make keys
```

3. Log in to Azure using the Azure CLI.

```bash
az login
```

3. Initialize Terraform in the project directory.

```bash
make init
```

4. Execute Terraform plan to preview the changes that will be applied.

```bash
make plan
```

5. If the plan looks good, apply the Terraform configuration to create the Azure resources.

```bash
make apply
```

7. Once the deployment is complete, Terraform will output the public IP address of the first manager node and the join token for Docker Swarm. Use this information to access and manage your Docker Swarm cluster.

## Accessing the Cluster

To access the Docker Swarm cluster:

1. SSH into the first manager node using the public IP address provided by Terraform.

```bash
ssh username@public_ip_address
```

2. Once logged into the manager node, you can interact with Docker Swarm using Docker CLI commands.

```bash
docker node ls           # List all nodes in the Swarm
docker service ls        # List all services running in the Swarm
docker stack deploy ...  # Deploy a new stack to the Swarm
```

## Cleaning Up

To clean up and delete all Azure resources created by Terraform:

1. Run Terraform destroy command.

```bash
terraform destroy
```

2. Confirm the destruction by typing `yes` when prompted.

## Customize Further

Feel free to customize this Terraform configuration according to your specific requirements. You can add more configurations, modify networking settings, change VM sizes, or integrate additional services into the Docker Swarm cluster.

## Important Notes

- Ensure that you have reviewed and understood the costs associated with running resources in Azure. Deleting resources after use can help minimize costs.
- Always follow security best practices when deploying resources in a cloud environment. Use secure credentials and configure appropriate network security rules.
- Regularly update Terraform versions and Azure CLI for the latest features and security patches.

## Troubleshooting

If you encounter any issues during deployment or usage, refer to the following resources:

- Terraform documentation: [Terraform Documentation](https://www.terraform.io/docs/index.html)
- Azure documentation: [Azure Documentation](https://docs.microsoft.com/en-us/azure/)
- Docker documentation: [Docker Documentation](https://docs.docker.com/)

For specific issues or questions related to this repository, feel free to open an issue or contact the repository owner.

## License

This project is licensed under the MIT License
