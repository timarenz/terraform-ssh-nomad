datacenter = "${datacenter}"
data_dir = "${data_dir}"
%{ if agent_type == "server" }
server {
  enabled = true
  bootstrap_expect = ${bootstrap_expect}
  server_join {
    retry_join = ${retry_join}
  }
}
%{ endif }
%{ if agent_type == "client" }
client {
  enabled = true
  server_join {
    retry_join = ${retry_join}
  }
}
%{ endif }
log_level = "${log_level}"
