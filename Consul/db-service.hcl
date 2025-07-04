service {
    id = "client2"
    name = "db"

    address = "172.31.0.184"
    port = 5001

    tags = ["v7.05", "production"]
    connect = { sidecar_service = {} }
}
