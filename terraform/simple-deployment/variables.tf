# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION

# AWS Provider
variable "region" {}
variable "access_key" {}
variable "secret_key" {}


# Install UCP 
variable "ucp_version" {
  description = "UCP Version"
}

variable "admin_username" {
  description = "Admin username"
}
variable "admin_password" {
  description = "Admin password"
}

# Manager resource

variable "ami_id" {
  description = "AMI ID"
}
variable "instance_type_manager" {
  default = "t2.large"
}
variable "ssh_key_name" {
    type = "string"
    default = "terraform"
}

variable "provisioning_user" {
    description = "The username used to SSH by the provisioner"
    default = "ec2-user"
}
variable "provisioning_key" {
    description = "The private key used to SSH by the provisioner"
    default = "~/aws/terraform.pem"
}
variable "private_key_path" {
  default = "~/aws/terraform.pem"
}