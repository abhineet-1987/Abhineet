node_name = "consul-server"
data_dir = "/opt/consul"
datacenter = "dc1"
ui_config = {
  enabled = true
}
server = true
log_level = "debug"
client_addr = "0.0.0.0"
bind_addr = "0.0.0.0"
advertise_addr = "192.168.64.12"
license_path = "/etc/consul.d/license.hclic"
bootstrap_expect = 1
connect {
  enabled = true
}
