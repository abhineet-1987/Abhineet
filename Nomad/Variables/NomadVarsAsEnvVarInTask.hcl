job "hello-world" {
  # Specifies the datacenter where this job should be run
  # This can be omitted and it will default to ["*"]
  datacenters = ["*"]

  meta {
    # User-defined key/value pairs that can be used in your jobs.
    # You can also use this meta block within Group and Task levels.
    foo = "bar"
  }

  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  group "servers" {

    # Specifies the number of instances of this group that should be running.
    # Use this to scale or parallelize your job.
    # This can be omitted and it will default to 1.
    count = 1


    network {
      mode = "bridge"
      port "www" {
        static = 8001
        to = 8001
      }
    }


    # Tasks are individual units of work that are run by Nomad.
    task "web" {
      # This particular task starts a simple web server within a Docker container
      driver = "docker"

      config {
        image   = "busybox:1"
        command = "httpd"
        args    = ["-v", "-f", "-p", "${NOMAD_PORT_www}", "-h", "/local"]
        ports   = ["www"]
      }

template {
  destination = "secrets/config.env"
  env         = true
  data = <<EOH
  {{ with nomadVar "s1/foo" -}}
  USER={{ .u }}
  PASS={{ .p }}
  {{ end }}
  EOH
}

      # Specify the maximum resources required to run the task
      resources {
        cpu    = 50
        memory = 64
      }
    }
  }
}
