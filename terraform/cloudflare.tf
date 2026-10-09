# Cloudflare DNS provider configuration stub
# Remove or populate this if Cloudflare is the intended DNS provider for the target.

# Example:
# resource "cloudflare_record" "cname" {
#   zone_id = var.cloudflare_zone_id
#   name    = local.cname_record_name
#   value   = azurerm_static_web_app.signup.default_host_name
#   type    = "CNAME"
#   proxied = true
# }
