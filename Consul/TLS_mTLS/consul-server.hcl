server           = true
bootstrap_expect = 1
datacenter       = "dc1"

bind_addr   = "0.0.0.0"
client_addr = "0.0.0.0"
data_dir    = "/opt/consul"

node_name = "server"


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
  allow_tls = true
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
    cert_file = "dc1-server-consul-0.pem"
    key_file  = "dc1-server-consul-0-key.pem"
  }
}

# -------------------------
# UI
# -------------------------
ui_config {
  enabled = true
}
