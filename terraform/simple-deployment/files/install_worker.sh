#!/bin/bash
# This script can be used to install workers
#

set -e

function log {
  local readonly level="$1"
  local readonly message="$2"
  local readonly timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
}

function log_info {
  local readonly message="$1"
  log "INFO" "$message"
}

function log_warn {
  local readonly message="$1"
  log "WARN" "$message"
}

function log_error {
  local readonly message="$1"
  log "ERROR" "$message"
}

function assert_not_empty {
  local readonly arg_name="$1"
  local readonly arg_value="$2"

  if [[ -z "$arg_value" ]]; then
    log_error "The value for '$arg_name' cannot be empty"
    print_usage
    exit 1
  fi
}



function install_worker {
  local readonly ucp_version="$1"
  local readonly admin_username="$2"
  local readonly admin_password="$3"
  local readonly instance_id="$4"
  local readonly private_ip="$5"
  local readonly manager_ip="$6"
  local readonly manager_public_dns="$7"

  local is_manager=false
  local have_docker_subscription=false

get_credentials() {
  cat << EOF
{
  "username": "$admin_username",
  "password": "$admin_password"
}
EOF
}

  log_info "Installing UCP Worker"

  if [[ -s /tmp/docker_subscription.lic ]]; then
    have_docker_subscription=true
  fi

  log_info "Wait for manager..."
  sleep 10
  timeout 22 bash -c 'until printf "" 2>>/dev/null >>/dev/tcp/$0/$1; do sleep 1; done' $manager_ip 2377

  log_info "Joining swarm as worker: $instance_id $private_ip $manager_ip $manager_public_dns"
  log_info "Getting worker join token"

  AUTH_TOKEN=$(curl -k -X POST "https://$manager_public_dns/auth/login" -H  "accept: application/json" -H  "content-type: application/json" -d "$(get_credentials)"|jq -r ".auth_token");
  curl -k -X GET "https://$manager_public_dns/swarm" -H  "accept: application/json" -H "Authorization: Bearer $AUTH_TOKEN"|jq -r ".JoinTokens.Worker"
  WORKER_TOKEN=$(curl -k -X GET "https://$manager_public_dns/swarm" -H  "accept: application/json" -H "Authorization: Bearer $AUTH_TOKEN"|jq -r ".JoinTokens.Worker");

  assert_not_empty "ucp auth_token" "$AUTH_TOKEN"
  assert_not_empty "ucp worker_token" "$WORKER_TOKEN"

  log_info "Joining swarm as manager, connecting to $manager_ip:2377 with token $WORKER_TOKEN"
  sudo -E docker swarm join --token $WORKER_TOKEN $manager_ip:2377;
}
 
function install {
  local ucp_version=""
  local admin_username=""
  local admin_password=""
  local instance_id=""
  local private_ip=""
  local manager_ip=""
  local manager_public_dns=""

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --ucp_version)
        ucp_version="$2"
        shift
        ;;
      --admin_username)
        admin_username="$2"
        shift
        ;;
      --admin_password)
        admin_password="$2"
        shift
        ;;
      --instance_id)
        instance_id="$2"
        shift
        ;;
      --private_ip)
        private_ip="$2"
        shift
        ;;
      --manager_ip)
        manager_ip="$2"
        shift
        ;;
      --manager_public_dns)
        manager_public_dns="$2"
        shift
        ;;
      --help)
        print_usage
        exit
        ;;
      *)
        log_error "Unrecognized argument: $key"
        print_usage
        exit 1
        ;;
    esac

    shift
  done

  assert_not_empty "--ucp_version" "$ucp_version"
  assert_not_empty "--admin_username" "$admin_username"
  assert_not_empty "--admin_password" "$admin_password"
  assert_not_empty "--instance_id" "$instance_id"
  assert_not_empty "--private_ip" "$private_ip"
  assert_not_empty "--manger_ip" "$manager_ip"
  assert_not_empty "--manager_public_dns" "$manager_public_dns"

  install_worker $ucp_version $admin_username $admin_password $instance_id $private_ip $manager_ip $manager_public_dns
}

install "$@"