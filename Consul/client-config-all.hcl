node_name = "client1"
datacenter = "my-dc-1"
data_dir = "/opt/consul"
ui_config{
  enabled = true
}
server = false
client_addr = "0.0.0.0"
bind_addr = "0.0.0.0"
advertise_addr = "172.31.8.233"
#retry_join = ["172.31.8.178"]
retry_join = ["provider=aws tag_key=purpose tag_value=consul-lab region=us-west-2"]
encrypt = "zeloSjN2voJsNpJ8G7qZ+Zf3jvCewxzLRkMkcygXtbI="
tls {
   defaults {
      ca_file = "/etc/consul.d/certs/consul-agent-ca.pem"
      verify_incoming = true
      verify_outgoing = true
   }
   internal_rpc {
      verify_server_hostname = true
   }
}

auto_encrypt {
  tls = true
}
acl {
  enabled = true
  default_policy = "deny"
  tokens {
    agent  = "189be838-4b4c-3671-95e3-dfc57b433e6b"
  }
}
connect = {
  enabled = true
}
