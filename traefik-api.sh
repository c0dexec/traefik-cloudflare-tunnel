#!/bin/bash

function lb_ip {

    local routers=$(curl -sG http://10.0.0.3:9000/api/http/services | jq -c '.[]')

    # "while" loop is used rather than "for" as the number of itterations are unknown
    while read route
    do
        echo $route | jq -c '."name"' | grep vaultwarden > /dev/null
        if [ $? -lt 1 ];
        then
            ip_addr=$(jq -c '.loadBalancer.servers[].url')
        else
            continue
        fi <<< $route
    done <<< $routers
}

function update_cloudflare {
    lb_ip
    local api_token="$cloudflare_api_token"
    local account_id="$account_id"
    local tunnel_id="$tunnel_id"

    local data=$(cat <<EOF
{
  "config": {
    "ingress": [
      {
        "service": $ip_addr,
        "hostname": "vaultwarden.c0dexec.dev",
        "originRequest": {}
      },
      {
        "service": "http_status:404"
      }
    ]
  }
}
EOF
)

    curl  -X PUT \
  "https://api.cloudflare.com/client/v4/accounts/${account_id}/cfd_tunnel/${tunnel_id}/configurations" \
  --header "Authorization: Bearer $api_token" \
  --header 'Content-Type: application/json' \
  --data-raw "$data"
    
}

update_cloudflare
