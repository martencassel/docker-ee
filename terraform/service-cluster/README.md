https://docs.docker.com/ee/ucp/interlock/usage/service-clusters/

```
eight (8) node swarm,
(3) managers and five (5) workers

two workers are configured with node labels to be dedicated ingress cluster
load balancer nodes: lb-00, lb-01

Pin the ucp-interlock-proxy service to lb-00, lb-01

$> docker node update --label-add nodetype=loadbalancer --label-add region=us-east lb-00
lb-00
$> docker node update --label-add nodetype=loadbalancer --label-add region=us-west lb-01
lb-01

cat << EOF | docker config create service.interlock.conf -
ListenAddr = ":8080"
DockerURL = "unix:///var/run/docker.sock"
PollInterval = "3s"

[Extensions]
  [Extensions.us-east]
    Image = "interlockpreview/interlock-extension-nginx:2.0.0-preview"
    Args = ["-D"]
    ServiceName = "interlock-ext-us-east"
    ProxyImage = "nginx:alpine"
    ProxyArgs = []
    ProxyServiceName = "interlock-proxy-us-east"
    ProxyConfigPath = "/etc/nginx/nginx.conf"
    ServiceCluster = "us-east"
    PublishMode = "host"
    PublishedPort = 80
    TargetPort = 80
    PublishedSSLPort = 443
    TargetSSLPort = 443
    [Extensions.us-east.Config]
      User = "nginx"
      PidPath = "/var/run/proxy.pid"
      WorkerProcesses = 1
      RlimitNoFile = 65535
      MaxConnections = 2048
    [Extensions.us-east.Labels]
      ext_region = "us-east"
    [Extensions.us-east.ProxyLabels]
      proxy_region = "us-east"

  [Extensions.us-west]
    Image = "interlockpreview/interlock-extension-nginx:2.0.0-preview"
    Args = ["-D"]
    ServiceName = "interlock-ext-us-west"
    ProxyImage = "nginx:alpine"
    ProxyArgs = []
    ProxyServiceName = "interlock-proxy-us-west"
    ProxyConfigPath = "/etc/nginx/nginx.conf"
    ServiceCluster = "us-west"
    PublishMode = "host"
    PublishedPort = 80
    TargetPort = 80
    PublishedSSLPort = 443
    TargetSSLPort = 443
    [Extensions.us-west.Config]
      User = "nginx"
      PidPath = "/var/run/proxy.pid"
      WorkerProcesses = 1
      RlimitNoFile = 65535
      MaxConnections = 2048
    [Extensions.us-west.Labels]
      ext_region = "us-west"
    [Extensions.us-west.ProxyLabels]
      proxy_region = "us-west"
EOF
oqkvv1asncf6p2axhx41vylgt


docker network create -d overlay interlock


docker service create \
    --name interlock \
    --mount src=/var/run/docker.sock,dst=/var/run/docker.sock,type=bind \
    --network interlock \
    --constraint node.role==manager \
    --config src=service.interlock.conf,target=/config.toml \
    interlockpreview/interlock:2.0.0-preview -D run -c /config.toml
sjpgq7h621exno6svdnsvpv9z


$> docker service update \
    --constraint-add node.labels.nodetype==loadbalancer \
    --constraint-add node.labels.region==us-east \
    interlock-proxy-us-east
$> docker service update \
    --constraint-add node.labels.nodetype==loadbalancer \
    --constraint-add node.labels.region==us-west \
    interlock-proxy-us-west