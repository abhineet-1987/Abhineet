service {
    id = "client2"
    name = "db"

    address = "127.0.0.1"
    port = 5001

    tags = ["v7.05", "production"]
    connect = { sidecar_service = {} }
    check = {
        id = "db-healthcheck"
        name = "Check db on port 5001"
        tcp = "localhost:5001"
        interval = "10s"
        timeout = "1s"
    }
}
