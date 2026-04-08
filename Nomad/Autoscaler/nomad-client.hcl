datacenter = "dc1"
data_dir = "/opt/nomad"
telemetry {
  collection_interval = "10s"
  prometheus_metrics   = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
  disable_hostname           = true 
}

client {
  enabled = true
  servers = ["<ip-of-nommad-server>"]
}
