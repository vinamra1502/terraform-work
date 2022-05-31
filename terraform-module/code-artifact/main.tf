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
