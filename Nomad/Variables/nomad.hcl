datacenter = "dc1"
data_dir = "/opt/nomad"
acl {
  enabled = true
}
server {
  license_path = "/etc/nomad.d/license.hclic"
  enabled = true
  bootstrap_expect = 1
}
client {
  enabled = true
  servers = ["172.31.1.40"]
}
