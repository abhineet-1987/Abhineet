plugin_dir = "/plugins"
nomad {
 address   = "http://<nomad-client-ip>:4646"
}
apm "nomad" {
 driver = "nomad-apm"
 config = {
  address   = "http://<nomad-client-ip>:4646"
 }
}
apm "prometheus" {
 driver = "prometheus"
 config = {
  address   = "http://<nomad-server-ip>:9090"
 }
}
dynamic_application_sizing {
 evaluate_after = "5m"
}
strategy "target-value" {
 driver = "target-value"
}
policy_eval {
 ack_timeout  = "5m"
 delivery_limit = 4
 workers = {
  cluster   = 10
  horizontal  = 10
  vertical_mem = 10
  vertical_cpu = 10
 }
}
