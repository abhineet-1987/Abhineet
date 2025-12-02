data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

client {
  enabled          = true
  server_join {
  retry_join = [ "192.168.64.5", "192.168.64.8", "192.168.64.9" ]
}
}

# Require TLS
tls {
  http = true
  rpc  = true

  ca_file   = "/home/ubuntu/nomad-agent-ca.pem"
  cert_file = "/home/ubuntu/global-client-nomad.pem"
  key_file  = "/home/ubuntu/global-client-nomad-key.pem"

  verify_server_hostname = true
  verify_https_client    = true
}
