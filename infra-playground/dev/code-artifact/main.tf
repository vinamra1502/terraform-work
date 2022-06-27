module "codeartifact_lessen" {
  source  = "../../../terraform-module/code-artifact/"
  domain_name = var.domain_name
  environment = var.environment
  repo_name   = var.repo_name
  cluster_vertical  = var.cluster_vertical

}
