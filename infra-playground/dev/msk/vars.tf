variable "cluster_name" {}
variable "instance_type" {}
variable "number_of_nodes" {}
variable "kafka_version" {}
variable "volume_size" {}
variable "vpc_cidr" {}
variable "private_subnets_cidr" {}
variable "enhanced_monitoring" {}
variable "prometheus_jmx_exporter" {}
variable "prometheus_node_exporter" {}
variable "encryption_in_transit_client_broker" {}
variable "Owner" {}
variable "Environment" {}
variable "Component" {}
variable "server_properties" {
  type    = map(string)
}
