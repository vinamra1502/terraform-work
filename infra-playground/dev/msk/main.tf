module "msk-cluster" {
  source  = "../../../terraform-module/msk/"

  cluster_name    = var.cluster_name
  instance_type   = var.instance_type
  number_of_nodes = var.number_of_nodes
  kafka_version   = var.kafka_version
  volume_size     = var.volume_size
  vpc_cidr          = var.vpc_cidr
  private_subnets_cidr  = var.private_subnets_cidr


  enhanced_monitoring = var.enhanced_monitoring

  # s3_logs_bucket = "testingsbucket"
  # s3_logs_prefix = "msklogs"

  prometheus_jmx_exporter  = var.prometheus_jmx_exporter
  prometheus_node_exporter = var.prometheus_node_exporter

  server_properties = var.server_properties
  encryption_in_transit_client_broker = var.encryption_in_transit_client_broker

  tags = {
    Owner       = var.Owner
    Environment = var.Environment
    Component   = var.Component
  }
}
