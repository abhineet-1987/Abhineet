Kind = "service-router"
Name = "api"

Routes = [
  {
    Match {
      HTTP {
        PathPrefix = "/v1"
      }
    }
    Destination {
      ServiceSubset = "v1"
      PrefixRewrite = "/"  # This strips /v1 and sends / to the app
    }
  },
  {
    Match {
      HTTP {
        PathPrefix = "/v2"
      }
    }
    Destination {
      ServiceSubset = "v2"
      PrefixRewrite = "/"  # This strips /v2 and sends / to the app
    }
  },
  {
    Match {
      HTTP {
        PathPrefix = "/distribute"
      }
    }
    Destination {
      Service       = "api"
      PrefixRewrite = "/"  # This strips /distribute and sends / to the app
    }
  },
  {
    Match {
      HTTP {
        PathPrefix = "/" 
      }
    }
    Destination {
      Service = "legacy-app"
    }
  }
]
