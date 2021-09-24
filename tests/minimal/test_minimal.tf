terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    aci = {
      source  = "netascode/aci"
      version = ">=0.2.0"
    }
  }
}

resource "aci_rest" "fvTenant" {
  dn         = "uni/tn-TF"
  class_name = "fvTenant"
}

module "main" {
  source = "../.."

  tenant = aci_rest.fvTenant.content.name
  name   = "DEV1"
}

data "aci_rest" "vnsLDevVip" {
  dn = "uni/tn-${aci_rest.fvTenant.content.name}/lDevVip-${module.main.name}"

  depends_on = [module.main]
}

resource "test_assertions" "vnsLDevVip" {
  component = "vnsLDevVip"

  equal "name" {
    description = "name"
    got         = data.aci_rest.vnsLDevVip.content.name
    want        = module.main.name
  }
}
