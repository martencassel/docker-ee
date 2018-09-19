terraform init

terraform plan \
  -var-file="secret.tfvars" \
  -var-file="swarm-example.tfvars" -lock=false

terraform apply \
  -var-file="secret.tfvars" \
  -var-file="swarm-example.tfvars" -lock=false
  
terraform destroy \
  -var-file="secret.tfvars" \
  -var-file="swarm-example.tfvars" \
  -force -lock=false
