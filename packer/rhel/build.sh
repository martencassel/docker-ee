#!/bin/sh

source ../secrets.sh

#
# RHEL 7.5
#

# 17.06.2.ee-16
export OS_NAME="RHEL7.5"
export DOCKER_EE_FQDN="docker-ee-17.06.2.ee.16-3.el7"
export OS_AMI_ID="ami-c86c3f23"
packer build packer_aws_ee_rhel.json

# 17.06.2.ee-15
export OS_NAME="RHEL7.5"
export DOCKER_EE_FQDN="docker-ee-17.06.2.ee.15-3.el7"
export OS_AMI_ID="ami-c86c3f23"
packer build packer_aws_ee_rhel.json

# 17.06.2.ee.14
export OS_NAME="RHEL7.5"
export DOCKER_EE_FQDN="docker-ee-17.06.2.ee.14-3.el7"
export OS_AMI_ID="ami-c86c3f23"
packer build packer_aws_ee_rhel.json
 