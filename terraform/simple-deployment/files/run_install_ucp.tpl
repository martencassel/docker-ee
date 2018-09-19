#!/bin/sh

ucp_version="${ucp_version}";
admin_username="${admin_username}";
admin_password="${admin_password}";

instance_id=$1;
private_ip=$2;
manager_ip=$3;
manager_public_dns=$4;

chmod +x /tmp/install_ucp.sh;

/tmp/install_ucp.sh \
    --ucp_version $ucp_version \
    --admin_username $admin_username \
    --admin_password $admin_password \
    --instance_id $instance_id \
    --private_ip $private_ip \
    --manager_ip $manager_ip \
    --manager_public_dns $manager_public_dns;