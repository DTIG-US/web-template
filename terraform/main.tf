variable "location" {
  type    = string
  default = "Central US"
}

resource "azurerm_resource_group" "rg" {
  name     = "IH-WWW-${upper(var.environment)}"
  location = var.location
}

locals {
  swa_name            = "ih-www-${upper(var.environment)}"
  swa_dns_auth_record = "dnsauth_${var.swa_custom_domain}"
}
