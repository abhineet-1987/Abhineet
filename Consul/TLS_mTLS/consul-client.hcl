# -------------------------
server           = false
datacenter       = "dc1"

bind_addr   = "0.0.0.0"
client_addr = "0.0.0.0"
data_dir    = "/opt/consul"
node_name = "client"
retry_join = ["<consul-server-ip>"]

# -------------------------
# ACL configuration
# -------------------------
acl {
  enabled = false
}

# -------------------------
# Connect / Service Mesh
# -------------------------
connect {
  enabled = true
}

ports {
  http      = -1
  https     = 8501
  grpc      = 8502
  grpc_tls  = 8503
}

auto_encrypt {
  tls = true
}

# -------------------------
# TLS configuration
# -------------------------
tls {

  defaults {
    verify_incoming = false
    verify_outgoing = false
    verify_server_hostname = false
    ca_file   = "consul-agent-ca.pem"
  }
}

# -------------------------
# UI
# -------------------------
ui_config {
  enabled = true
}
