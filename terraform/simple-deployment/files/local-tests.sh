#!/bin/sh
export MANAGER_PUBLIC_DNS=$1
export ADMIN_USERNAME=$2
export ADMIN_PASSWORD=$3

echo "local: MANAGER_PUBLIC_DNS: $1, ADMIN_USERNAME: $ADMIN_USERNAME"

# 1. Get client bundle

echo "Getting client bundle"
LAST_PWD=$(pwd)
mkdir -p ~/.ucp/
AUTHTOKEN=$(curl -sk -d "{\"username\":\"$ADMIN_USERNAME\",\"password\":\"$ADMIN_PASSWORD\"}" https://$MANAGER_PUBLIC_DNS/auth/login | jq -r .auth_token)
curl -k -H "Authorization: Bearer $AUTHTOKEN" https://$MANAGER_PUBLIC_DNS/api/clientbundle -o ~/.ucp/bundle.zip
cd ~/.ucp && unzip -o ~/.ucp/bundle.zip
eval "$(<env.sh)"
cd $LAST_PWD

docker node ls

# 2. Enable HTTP routing
echo "Enabling HTTP routing"
curl -sk  -H "Authorization: Bearer $AUTHTOKEN" -d '{"HTTPPort": 80, "HTTPSPort": 8443, "Arch": "x86_64"}' https://$MANAGER_PUBLIC_DNS/api/interlock

# 3. Check that interlock is deployed
echo "Check that interlock was deployed"

COUNT_INTERLOCK=$(docker service ls|grep ucp-interlock|wc -l)
echo "Interlock services: $COUNT_INTERLOCK"

# 4. Deploy simple swarm service
echo "Deploy simple swarm service"
docker stack deploy --compose-file ucp-interlock-demo.yml interlock-demo

# 5. Test using CLI
echo "Test app.example.org, sleeping in 10 seconds"
#sleep 10
curl --header "Host: app.example.org" http://$MANAGER_PUBLIC_DNS:80/ping
# 6. Set default service
docker stack deploy --compose-file ucp-interlock-default.yml default

# 7. Test default service
curl --header "Host: nothing.example.org" \
    http://$MANAGER_PUBLIC_DNS:80|grep "There is no application configured for this host."

# 8. Context/path based routing
docker network create -d overlay demo
docker service create \
    --name demo-path-routing \
    --network demo \
    --detach=false \
    --label com.docker.lb.hosts=demo.local \
    --label com.docker.lb.port=8080 \
    --label com.docker.lb.context_root=/app \
    --label com.docker.lb.context_root_rewrite=true \
    --env METADATA="demo-context-root" \
    ehazlett/docker-demo

curl -vs -H "Host: demo.local" http://$MANAGER_PUBLIC_DNS/app/