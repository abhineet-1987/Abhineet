node_name = "server1"
datacenter = "my-dc-1"
data_dir = "/opt/consul"
ui_config{
  enabled = true
}
server = true
client_addr = "0.0.0.0"
bind_addr = "0.0.0.0"
advertise_addr = "172.31.8.178"
bootstrap_expect=1
#retry_join = ["172.31.8.233"]
retry_join = ["provider=aws tag_key=purpose tag_value=consul-lab region=us-west-2"]
encrypt = "zeloSjN2voJsNpJ8G7qZ+Zf3jvCewxzLRkMkcygXtbI="
tls {
   defaults {
      ca_file = "/etc/consul.d/certs/consul-agent-ca.pem"
      cert_file = "/etc/consul.d/certs/my-dc-1-server-consul-0.pem"
      key_file = "/etc/consul.d/certs/my-dc-1-server-consul-0-key.pem"

      verify_incoming = true
      verify_outgoing = true
   }
   internal_rpc {
      verify_server_hostname = true
   }
}

auto_encrypt {
  allow_tls = true
}
performance {
  raft_multiplier = 1
}
acl = {
  enabled        = true
  default_policy = "deny"
  down_policy    = "extend-cache"
  enable_token_persistence = true
}
connect = {
  enabled = true
}
