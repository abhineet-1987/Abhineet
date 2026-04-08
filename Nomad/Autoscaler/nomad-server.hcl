datacenter = "dc1"
data_dir = "/opt/nomad"
telemetry {
  collection_interval = "10s"
  prometheus_metrics   = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
  disable_hostname           = true 
}

server {
  license_path = "/etc/nomad.d/license.hclic"
  enabled = true
  bootstrap_expect = 1
}
