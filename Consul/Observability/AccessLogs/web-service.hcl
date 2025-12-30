service {
    id = "client1"
    name = "web"

    address = "127.0.0.1"
    port = 5002

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
check = {
        id = "web-healthcheck"
        name = "Check web on port 5002"
        tcp = "localhost:5002"
        interval = "10s"
        timeout = "1s"
    }
}
