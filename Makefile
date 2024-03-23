# Set environment variables
export ADMIN_USERNAME?=vm_admin

SSH_KEY_FILES:=$(ADMIN_USERNAME).pem $(ADMIN_USERNAME).pub
SSH_KEY:=$(ADMIN_USERNAME).pem

# Generate SSH keys for the cluster
keys:
	mkdir keys
	ssh-keygen -b 2048 -t rsa -f keys/$(ADMIN_USERNAME) -q -N ""
	mv keys/$(ADMIN_USERNAME) keys/$(ADMIN_USERNAME).pem

	echo 'ssh_private_key_local_path = "keys/$(ADMIN_USERNAME).pub"' > terraform.tfvars
	echo 'vm_admin_username = "$(ADMIN_USERNAME)"' >> terraform.tfvars

# Initialize terraform
init:
	terraform init

# Generate the terraform plan:
plan: init
	terraform plan -var-file=terraform.tfvars -out=terraform.plan

# Apply the terraform plan:
apply: init
	terraform apply terraform.plan