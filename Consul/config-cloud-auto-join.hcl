datacenter = "my-dc-1"
data_dir = "/opt/consul"
ui_config{
  enabled = true
}
server = true
client_addr = "0.0.0.0"
bind_addr = "0.0.0.0"
advertise_addr = "172.31.4.132"
bootstrap_expect=2
retry_join = ["provider=aws tag_key=purpose tag_value=consul-lab region=us-west-2"]
#If you get this error during join operation Cannot discover address: cluster=LAN address="provider=aws tag_key=purpose tag_value=consul-lab region=us-west-2" error="discover-aws: DescribeInstancesInput failed: operation error EC2: DescribeInstances, get identity: get credentials: failed to refresh cached credentials, no EC2 IMDS role found, operation error ec2imds: GetMetadata, http response error StatusCode: 404, request to EC2 IMDS failed"
# Please create IAM role to DescribeEC2Instances and attach that role to each of the cluster nodes
