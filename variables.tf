variable "dependency" {
  description = "Allows this module to depend and therefore wait on other resources"
  type        = string
  default     = null
}

variable "host" {
  description = "IP address, hostname or dns name of the machine that should become a Consul agent"
  type        = string
}

variable "username" {
  description = "Username used for SSH connection"
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private key used for SSH connection"
  type        = string
}

variable "nomad_binary" {
  description = "Path to nomad binary that should be uploaded. If not specified a version will be download from releases.hashicorp.com"
  type        = string
  default     = null
}

variable "nomad_version" {
  description = "If specified this version will be downloaded from releases.hashicorp.com, if not the latest version will be used"
  type        = string
  default     = null
}

variable "data_dir" {
  description = "Specifies a local directory used to store agent state. Client nodes use this directory by default to store temporary allocation data as well as cluster information. Server nodes use this directory to store cluster state, including the replicated log and snapshot data. This must be specified as an absolute path. (https://www.nomadproject.io/docs/configuration/index.html#data_dir)"
  type        = string
  default     = "/opt/nomad"
}

variable "agent_type" {
  description = "This flag is used to control if an agent is in server or client mode. Supported values: client or server. (https://www.consul.io/docs/agent/options.html#_server)"
  type        = string
  default     = "server"
}

variable "datacenter" {
  description = "Specifies the data center of the local agent. All members of a datacenter should share a local LAN connection. (https://www.nomadproject.io/docs/configuration/index.html#datacenter)"
  type        = string
  default     = "dc1"
}

variable "primary_datacenter" {
  description = "This designates the datacenter which is authoritative for ACL information, intentions and is the root Certificate Authority for Connect. It must be provided to enable ACLs. All servers and datacenters must agree on the primary datacenter. (https://www.consul.io/docs/agent/options.html#primary_datacenter)"
  type        = string
  default     = null
}

variable "log_level" {
  description = "Specifies the verbosity of logs the Nomad agent will output. Valid log levels include WARN, INFO, or DEBUG in increasing order of verbosity. (https://www.nomadproject.io/docs/configuration/index.html#log_level)"
  type        = string
  default     = "info"
}

variable "bootstrap_expect" {
  description = "Specifies the number of server nodes to wait for before bootstrapping. It is most common to use the odd-numbered integers 3 or 5 for this value, depending on the cluster size. A value of 1 does not provide any fault tolerance and is not recommended for production use cases. (https://www.nomadproject.io/docs/configuration/server.html#bootstrap_expect)"
  type        = number
  default     = 3
}

variable "retry_join" {
  description = " Specifies a list of server addresses to join. This is similar to start_join, but will continue to be attempted even if the initial join attempt fails, up to retry_max. (https://www.nomadproject.io/docs/configuration/server_join.html#retry_join)"
  type        = list(string)
}
