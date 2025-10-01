node_name = "consul-server"
data_dir = "/opt/consul"
ui_config = {
  enabled = true
}
server = true
client_addr = "0.0.0.0"
bind_addr = "0.0.0.0"
advertise_addr = "172.31.1.40"
license_path = "/etc/consul.d/license.hclic"
bootstrap_expect=1
ports = {
  grpc = 8502
}
connect = {
  enabled = true
}
