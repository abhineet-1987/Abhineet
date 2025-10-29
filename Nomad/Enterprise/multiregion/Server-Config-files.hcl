Reference Document: https://developer.hashicorp.com/nomad/tutorials/archive/federation
                    https://developer.hashicorp.com/nomad/tutorials/enterprise/production-reference-architecture-vm-with-consul#deployment-topology-across-multiple-regions

%%%%%%%% EAST REGION CONFIG %%%%%%%%%%%
################## nomad.hcl ###################
datacenter = "dc1"
data_dir = "/opt/nomad"
region = "east"
################## server.hcl #################
server {
  license_path = "/etc/nomad.d/license.hclic"
  enabled = true
  bootstrap_expect = 3
  authoritative_region = "east"
  server_join {
    retry_join = ["172.31.1.40","172.31.21.224","172.31.30.205"]
}
}

%%%%%%%% WEST REGION CONFIG %%%%%%%%%%%
################## nomad.hcl ###################
datacenter = "dc2"
data_dir = "/opt/nomad"
region = "west"
################## server.hcl #################
server {
  license_path = "/etc/nomad.d/license.hclic"
  enabled = true
  bootstrap_expect = 1
  authoritative_region = "east"
  server_join {
    retry_join = ["172.31.1.40","172.31.21.224","172.31.30.205"]
}
}

Note:
1. A single region can have multiple datacenters.
2. One DC can be associated with one region only.
3. For federating two region use "nomad server join 172.31.26.138:4648" command or use server_join in server.hcl. If leader is not getting elected in any region when you've used server_join, then try deleting data dir + start nomad and then see.
4. To verify the clusters have been federated :
          run "nomad server members" command
          run "nomad status -region="east" from the Nomad cluster in the west region to check the status of jobs in the east region and vice versa.
5. Running "nomad operator raft list-peers" will give leader and follower status for each region.
6. There should be only one leader for one region.
