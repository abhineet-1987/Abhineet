Kind = "http-route"
Name = "http-route-manual"

// Rules define how requests will be routed
Rules = [
  {
    Matches = [
      {
        Path = {
          Match = "prefix"
          Value = "/"
        }
      }
    ]
    Services = [
      {
        Name = "nginx12eks"
      }
    ]
  }
]

  Parents = [
  {
    Kind = "api-gateway"
    Name = "agw-manual"
    SectionName = "agw-manual-listener"
  }
]
