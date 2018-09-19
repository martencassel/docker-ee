LAST_DIR=$PWD

cd ..

terraform init

# OS: RHEL 7.5, EE: 17.06.02-ee-14-3, UCP: 3.0.5
terraform plan \
  -var-file="../secret.tfvars" \
  -var-file="../releases/305_rhel75_170602-14-3.tfvars" -lock=false

terraform apply \
  -var-file="../secret.tfvars" \
  -var-file="../releases/305_rhel75_170602-14-3.tfvars" -lock=false
  
#terraform destroy \
#  -var-file="../secret.tfvars" \
#  -var-file="../releases/305_rhel75_170602-14-3.tfvars" -lock=false
#  -force -lock=false

cd $LAST_DIR