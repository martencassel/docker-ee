#!/bin/sh

source ../secrets.sh

# Windows Server

# 17.06.2.ee.14
export OS_NAME="Windows2016"
export OS_AMI_ID="ami-049951c6a9c02b260"
packer build ./packer_aws_ee_win.json
