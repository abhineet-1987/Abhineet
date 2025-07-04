service {
    id = "client1"
    name = "web"

    address = "172.31.8.233"
    port = 5000

    tags = ["v7.05", "production"]
    connect {
    sidecar_service {
      proxy {
        upstreams = [
          {
            destination_name = "db"
            local_bind_port  = 9191
          }
        ]
      }
    }
  }
}
