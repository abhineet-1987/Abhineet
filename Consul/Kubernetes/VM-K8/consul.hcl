datacenter = "xds-dc"
data_dir = "/opt/consul"

ui_config {
  enabled = true
}

server = true
client_addr = "0.0.0.0"
bind_addr = "0.0.0.0"
advertise_addr = "ip1"
bootstrap_expect = 3
retry_join = ["ip1", "ip2", "ip3"]
license_path = "/etc/consul.d/license.hclic"

performance {
  enable_xds_load_balancing = true
}

ports {
  http     = 8500
  grpc     = 8502   # Mandatory for Envoy / K8s Workloads without TLS
  grpc_tls = -1     # Disabled
  https    = -1     # Disabled
}

xds {
  update_max_per_second = 1000
}

limits {
  # Maximum concurrent connections per client
  http_max_conns_per_client = 500
}

connect {
  enabled = true
}
