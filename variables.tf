variable "vm_file_path" {
    type = string
    default = ""
}

variable "datacenter" {
    type = string
    default = ""
}

variable "vlan" {
    type = string
    default = ""
}

# variable "compute_cluster" {
#     type = string
#     default = ""
# }

# variable "datastore_cluster" {
#     type = string
#     default = ""
# }

variable "resource_pool" {
    type = string
    default = ""
}

variable "host" {
    type = string
    default = ""
}

variable "datastore" {
    type = string
    default = ""
}

variable "domain" {
    type = string
}

variable "dns_servers" {
    type = list
}

variable "template" {
    type = string
    default = ""
}

variable "utc_clock" {
  type        = bool
  default     = false
  description = "Sets the clock to UTC time. Default is false."
}

variable "time_zone" {
  type = map(string)
  default = {
    # placeholders
    linux   = "America/Chicago"
    windows = 020
  }
  description = "Map of time zones for Windows and Linux deployments. Defaults to central time."
}

variable "domain_pass" {
    type = string
}

variable "domain_user" {
    type = string
}

variable "admin_pass" {
    type = string
}