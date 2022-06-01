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
              "Effect": "Allow",
              "Principal": {
                  "AWS": [
                      "arn:aws:iam::823208167079:role/dev-codebuild-project-role",
                      "arn:aws:iam::823208167079:root"


                  ]
              },
              "Action": [
                   "codeartifact:GetAuthorizationToken"


              ],
              "Resource": "*"
          }
      ]
  }
EOF
}

resource "aws_codeartifact_repository" "this" {
  repository = var.repo_name
  depends_on       = [aws_codeartifact_domain.this]
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
              "Sid": "Sid0",
              "Effect": "Allow",
              "Principal": {
                  "AWS": [
                      "arn:aws:iam::823208167079:role/dev-codebuild-project-role",
                      "arn:aws:iam::823208167079:root"


                  ]
              },
              "Action": [
                   "codeartifact:Describe*",
                   "codeartifact:Get*",
                   "codeartifact:List*",
                   "codeartifact:ReadFromRepository"

              ],
              "Resource": "*"
          },
          {
              "Sid": "Sid1",
              "Effect": "Allow",
              "Principal": {
                  "AWS": [
                      "arn:aws:iam::823208167079:role/dev-codebuild-project-role"



                  ]
              },
              "Action": [

                   "codeartifact:PublishPackageVersion"

              ],
              "Resource": "*"
          }
      ]


  }
EOF
}
