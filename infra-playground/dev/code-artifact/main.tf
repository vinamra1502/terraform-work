module "codeartifact_lessen" {
  source  = "../../../terraform-module/code-artifact/"
  domain_name = "codeartifact-domain"
  environment = "prod"
  repo_name   = "codeartifact-repo"

}
