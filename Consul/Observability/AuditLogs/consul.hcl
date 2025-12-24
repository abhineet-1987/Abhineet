node_name = "consul-server"
data_dir = "/Users/abhineet/Documents/test/observ/audit/opt/consul"
datacenter = "dc9"
ui_config = {
  enabled = true
}
acl {
 enabled = true
}
server = true
log_level = "debug"
client_addr = "0.0.0.0"
bind_addr = "0.0.0.0"
advertise_addr = "127.0.0.1"
license_path = "/Users/abhineet/Documents/test/observ/audit/license.hclic"
bootstrap_expect = 1
audit {
  enabled = true
  sink "My sink" {
    type   = "file"
    format = "json"
    path   = "/Users/abhineet/Documents/test/observ/audit/audit.json"
    delivery_guarantee = "best-effort"
    rotate_duration = "24h"
  }
}
