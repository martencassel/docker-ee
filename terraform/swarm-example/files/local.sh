#!/bin/sh
export MANAGER_PUBLIC_DNS=$1
export ADMIN_USERNAME=$2
export ADMIN_PASSWORD=$3

echo "local: MANAGER_PUBLIC_DNS: $1, ADMIN_USERNAME: $ADMIN_USERNAME"

# 1. Get client bundle

echo "Getting client bundle"

AUTHTOKEN=$(curl -sk -d "{\"username\":\"$ADMIN_USERNAME\",\"password\":\"$ADMIN_PASSWORD\"}" https://$MANAGER_PUBLIC_DNS/auth/login | jq -r .auth_token)
mkdir -p ~/.ucp/
curl -k -H "Authorization: Bearer $AUTHTOKEN" https://$MANAGER_PUBLIC_DNS/api/clientbundle -o ~/.ucp/bundle.zip
unzip ~/.ucp/bundle.zip -d ~/.ucp/ -o
cd ~/.ucp/ && eval "$(<env.sh)" && cd -

# 2. Enable HTTP routing
echo "Enabling HTTP routing"
curl -sk  -H "Authorization: Bearer $AUTHTOKEN" -d '{"HTTPPort": 80, "HTTPSPort": 8443, "Arch": "x86_64"}' https://$MANAGER_PUBLIC_DNS/api/interlock

# 3. Check that interlock is deployed
echo "Check that interlock was deployed"

COUNT_INTERLOCK=$(docker service ls|grep ucp-interlock|wc -l)
echo "Interlock services: $COUNT_INTERLOCK"

# 4. Deploy simple swarm service
echo "Deploy simple swarm service"
docker stack deploy --compose-file ./ucp-interlock-demo.yml interlock-demo

# 5. Test using CLI
curl --header "Host: app.example.org" http://$MANAGER_PUBLIC_DNS:80/ping|jq