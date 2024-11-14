## This folder learn how to manage Terraform State and store it S3 bucket
# Note for this folder
# If you ever wanted to delete this S3 bucket and DynamoDB table :
- Go to the Terraform code , remove the backend configuration 
- Rerun terraform init to copy the Terraform state back to local disk
- Run terraform destroy  
# Every enviroments :
- stage : An environment for pre-production workloads (i.e., testing)
- prod : An environment for production workloads (i.e., user-facing apps)
- mgmt : An environment for DevOps tooling (e.g., bastion host, CI server)
- global : A place to put resources that are used across all environments (e.g., S3, IAM) 
# Within each enviroment , there are seprate folders :
- vpc 
- services
- data-storage
# Within each component, there are the actual Terraform configuration files
- variables.tf : input variables
- outputs.tf : Output variables
- main.tf : Resources and data sources
# Other files : 
- dependencies.tf 
- providers.tf
- main-xxx.tf