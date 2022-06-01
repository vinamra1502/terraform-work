resource "aws_kms_key" "this" {
  description = "domain key for aws_codeartifact_domain"
}

resource "aws_codeartifact_domain" "this" {
  domain = var.domain_name
  encryption_key = aws_kms_key.this.arn
  tags = {
      environment = var.environment
    }
}

resource "aws_codeartifact_domain_permissions_policy" "this" {
  domain          = aws_codeartifact_domain.this.domain
  count            = "${var.environment == "prod" ? 1 : 0}"
  policy_document = <<EOF
{
     "Version": "2012-10-17",
     "Statement": [
       {
        "Sid": "BasicDomainPolicy",
        "Effect": "Allow",
        "Action": "codeartifact:GetAuthorizationToken",
        "Resource": "${aws_codeartifact_domain.this.arn}",
        "Principal": {
          "AWS": "823208167079"
        }
        }
      ]
}
EOF
}

resource "aws_codeartifact_repository" "this" {
  repository = var.repo_name
  description = "This is our private Lessen repo. It has an external connection to public npm.js"
  domain          = aws_codeartifact_domain.this.domain

  external_connections {
    external_connection_name = "public:npmjs"
  }
  tags = {
      environment = var.environment
    }
}

resource "aws_codeartifact_repository_permissions_policy" "this" {
  repository      = aws_codeartifact_repository.this.repository
  domain          = aws_codeartifact_domain.this.domain
  policy_document = <<EOF
{
     "Version": "2012-10-17",
     "Statement": [
       {
        "Sid": "BasicRepoPolicy",
        "Effect": "Allow",
        "Action": [
             "codeartifact:Describe*",
             "codeartifact:Get*",
             "codeartifact:List*",
             "codeartifact:ReadFromRepository"

        ],
        "Resource": "${aws_codeartifact_domain.this.arn}",
        "Principal": {
          "AWS": "823208167079"
        }
        }
      ]
}
EOF
}
