data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

server {
  enabled          = true
  bootstrap_expect = 3
  server_join {
  retry_join = [ "192.168.64.5", "192.168.64.8", "192.168.64.9" ]
}
}

log_level = "DEBUG"


# Require TLS
tls {
  http = true
  rpc  = true

  ca_file   = "/home/ubuntu/nomad-agent-ca.pem"
  cert_file = "/home/ubuntu/global-server-nomad.pem"
  key_file  = "/home/ubuntu/global-server-nomad-key.pem"

  verify_server_hostname = true
  verify_https_client    = true
}
