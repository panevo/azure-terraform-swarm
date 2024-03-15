# Terraform Azure Cluster with Docker Swarm

## Overview

This repository contains Terraform code to deploy a cluster of virtual machines in Microsoft Azure with Docker Swarm fully configured. The machines are automatically provisioned using cloud-init. Each machine gets its own data disk, and file sharing is provided by mounting an Azure Storage File Share. The number of manager and worker nodes is configurable, and a basic Python server is started on the first manager node to share the Swarm join token with other nodes.

## Prerequisites

Before using this Terraform configuration, ensure you have the following prerequisites:

1. Azure subscription with the necessary permissions to create resources.
2. Terraform installed on your local machine. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).
3. Azure CLI installed for authentication and managing Azure resources. You can install it from [Azure CLI Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

## Usage

Follow these steps to deploy the Azure cluster with Docker Swarm:

1. Clone this repository to your local machine.

```bash
git clone https://github.com/yourusername/terraform-azure-docker-swarm.git
cd terraform-azure-docker-swarm
```

2. Initialize Terraform in the project directory.

```bash
terraform init
```

3. Modify the `variables.tf` file to configure your Azure settings and cluster parameters. You can specify the number of manager and worker nodes, Azure region, resource group name, VM sizes, etc.

4. Review and customize the cloud-init configuration files (`cloud-init/manager-init.yaml` and `cloud-init/worker-init.yaml`) according to your requirements. These files contain the configuration that will be applied to the VMs during provisioning.

5. Execute Terraform plan to preview the changes that will be applied.

```bash
terraform plan
```

6. If the plan looks good, apply the Terraform configuration to create the Azure resources.

```bash
terraform apply
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

3. Use the Swarm join token provided by Terraform to join worker nodes to the cluster.

```bash
docker swarm join --token <token> manager_ip:2377
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

## Contributors

- John Doe (@johndoe)
- Jane Smith (@janesmith)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
