## This folder learn how to manage Terraform State and store it S3 bucket
# Note for this folder
# If you ever wanted to delete this S3 bucket and DynamoDB table :
- Go to the Terraform code , remove the backend configuration 
- Rerun terraform init to copy the Terraform state back to local disk
- Run terraform destroy  
