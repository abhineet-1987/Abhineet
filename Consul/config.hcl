datacenter = "my-dc-1"
data_dir = "/opt/consul"
ui_config{
  enabled = true
}
server = true
client_addr = "0.0.0.0"
bind_addr = "0.0.0.0"
advertise_addr = "172.31.10.226"
bootstrap_expect=2
retry_join = ["172.31.2.126"]
