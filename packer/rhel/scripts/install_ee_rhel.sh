#!/bin/sh

function assert_not_empty {
  local readonly arg_name="$1"
  local readonly arg_value="$2"

  if [[ -z "$arg_value" ]]; then
    log_error "The value for '$arg_name' cannot be empty"
    print_usage
    exit 1
  fi
}

sudo usermod -aG docker ec2-user

sudo sh -c "echo 'SELINUX=disabled' > /etc/selinux/config"
sudo sh -c "getenforce"

assert_not_empty "DOCKER_URL" $DOCKER_URL
assert_not_empty "DOCKER_EE_FQDN" $DOCKER_EE_FQDN

sudo -E sh -c 'echo "$DOCKER_URL/rhel" > /etc/yum/vars/dockerurl'
sudo sh -c 'echo "7" > /etc/yum/vars/dockerosversion'

sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

sudo yum -y install wget;
sudo wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64;
sudo chmod +x ./jq;
sudo cp jq /usr/bin;

sudo yum-config-manager --enable rhui-REGION-rhel-server-extras

sudo -E yum-config-manager \
    --add-repo \
    "$DOCKER_URL/rhel/docker-ee.repo"

sudo yum -y install $DOCKER_EE_FQDN
sudo systemctl enable --now docker