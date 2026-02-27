# -------------------------
# Core server configuration
# -------------------------
server           = true
bootstrap_expect = 1
datacenter       = "dce"
primary_datacenter = "dce"
domain            = "consul-lab.myinfo.com"
node_name         = "primary-dc1-node"

encrypt = "xOq3gO9a3XXXXXXXXXXXXXXMYk="

bind_addr   = "0.0.0.0"
client_addr = "0.0.0.0"
data_dir    = "/opt/data"
license_path = "/etc/consul.d/license.hclic"


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
  enable_token_replication  = true
  tokens {
    agent = "d20affde-XXXXX-9ea9a7ab4209"
    replication = "d20affde-XXXXX-9ea9a7ab4209"
    default = "d20affde-XXXXX-9ea9a7ab4209"
  }
}

# -------------------------
# Connect / Service Mesh
# -------------------------
connect {
  enabled = true
  enable_mesh_gateway_wan_federation = true
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
  grpc_tls      = 8502
}

# -------------------------
# TLS configuration
# -------------------------
tls {
  internal_rpc {
    verify_incoming        = true
    verify_outgoing = true
    verify_server_hostname = true
  }

grpc {
    verify_incoming = false
  }


  defaults {
    ca_file   = "/etc/consul.d/tls_cust/consul-lab.myinfo.com-agent-ca.pem"
    cert_file = "/etc/consul.d/tls_cust/dce-server-consul-lab.myinfo.com-0.pem"
    key_file  = "/etc/consul.d/tls_cust/dce-server-consul-lab.myinfo.com-0-key.pem"
  }
}

# -------------------------
# UI
# -------------------------
ui_config {
  enabled = true
}
