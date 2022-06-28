module "monitoring" {
  source  = "../../../terraform-module/monitoring/"
  environment                  = "dev"
  cluster_vertical             = "platform"
}
