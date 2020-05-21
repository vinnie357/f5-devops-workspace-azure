# Azure Environment
variable projectPrefix { default = "workspace" }
variable adminAccountName { description = "your admin username" }
variable adminPassword { 
    description = "set to override random password"
    default = "" 
}
variable location { description = "location to deploy to" }
variable region { description = "region to deploy to" }
variable sshPublicKey { description = "contents of admin ssh public key" }
variable adminSourceAddress { description = "admin source address 100.100.100.10/32" }

# workspace
variable instanceType { default = "Standard_DS1_v2" }
variable diskType { default = "Premium_LRS"}
variable workspaceIp { default = "10.90.1.99" }
variable onboardScript { description = "URL to userdata onboard script"}
variable repositories { description = "comma seperated list of git repositories to clone"}

# NETWORK
variable cidr { default = "10.90.0.0/16" }
variable "subnets" {
  type = map(string)
  default = {
    "subnet1" = "10.90.1.0/24"
  }
}

# TAGS
variable purpose { default = "public" }
variable environment { default = "dev" } #ex. dev/staging/prod
variable owner { default = "dev" }
variable group { default = "dev" }
variable costcenter { default = "dev" }
variable application { default = "workspace" }