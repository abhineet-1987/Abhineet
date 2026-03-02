service {
  name = "static-client"
  port = 4321

  connect {
    sidecar_service {
      proxy {
        upstreams = [
          {
            destination_name = "static-server"
            datacenter       = "dc3-k3s"   # Match the DC name from your K8s setup
            local_bind_port  = 1234
          }
        ]
      }
    }
  }
}
