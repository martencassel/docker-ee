# node-1 (UCP manager, ucp-interlock)
# node-2 (UCP manager node)
# node-3 (UCP manager node)
# node-4 (UCP worker node, interlock-extension, wordpress:8000)
# node-5 (UCP worker node, interlock-proxy:80)
# node-6 (UCP worker node, interlock-proxy:80)
# your load balancer (backends: node-5, node-6, port 80)
# external route: http://wordpress.example.org


# Steps to setup

# 1. Apply labels to node
# 2. Configure the ucp-interlock service
# 3. Configure the load balancer

