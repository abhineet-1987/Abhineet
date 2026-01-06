# -------------------------
# Core server configuration
# -------------------------
server           = true
bootstrap_expect = 1
datacenter       = "dc2"
domain            = "consul"

bind_addr   = "0.0.0.0"
client_addr = "0.0.0.0"
data_dir    = "/consul/data"

retry_join = ["consul-server.default.svc:8301"]

leave_on_terminate = true
enable_debug       = false

# -------------------------
# ACL configuration
# -------------------------
acl {
  enabled                   = true
  default_policy            = "deny"
  down_policy               = "extend-cache"
  enable_token_persistence  = true
}

# -------------------------
# Connect / Service Mesh
# -------------------------
connect {
  enabled = true
}

enable_central_service_config = true

# -------------------------
# Limits
# -------------------------
limits {
  request_limits {
    mode       = "disabled"
    read_rate  = -1
    write_rate = -1
  }
}

# -------------------------
# Autopilot
# -------------------------
autopilot {
  min_quorum                = 1
  disable_upgrade_migration = true
}

# -------------------------
# Ports (merged from all files)
# -------------------------
ports {
  http      = -1
  https     = 8501
  grpc      = -1
  grpc_tls  = 8502
  serf_lan  = 8301
}

# -------------------------
# TLS configuration
# -------------------------
tls {
  internal_rpc {
    verify_incoming        = true
    verify_server_hostname = true
  }

  grpc {
    verify_incoming = false
  }

  defaults {
    verify_outgoing = true
    ca_file   = "/consul/tls/ca/tls.crt"
    cert_file = "/consul/tls/server/tls.crt"
    key_file  = "/consul/tls/server/tls.key"
  }
}

# -------------------------
# UI
# -------------------------
ui_config {
  enabled = true
}
