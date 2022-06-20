module "monitoring" {
  source  = "../../../terraform-module/monitoring/"
  environment                  = "dev"
  vpc_id                       = "vpc-018fa88e3a424abd0"
  subnet_ids                   = ["subnet-096c1bb06d73d8050", "subnet-0ed0cae2ff35ee447"]

}
