variable "name" {
  default = "test-postgres"
}
variable "vpc_id" {
  default = "vpc-0b98e2hj08fd46523"
}
variable "subnets" {
  description = "A list of subnets for rds subnet group"
  type        = list(string)
  default     = ["subnet-0a40579da542301a9", "subnet-03ba0b8cf6734560b","subnet-0f4aae01fc12098765"]
}

# variable "security_group" {
#   default = "sg-00d765c9ff3a824ca"
# }

variable "source_region" {
  default = "us-east-1"
}

variable "engine" {
  default = "postgres"
}

variable "engine_version" {
  default = "13.2"
}

variable "instance_class" {
  default = "db.t3.micro"
}

variable "allocated_storage" {
  default = "20"
}

variable "multi_az" {
  default = "false"
}

variable "publicly_accessible" {
  default = "false"
}

variable "auto_minor_version_upgrade" {
  default = "false"
}

variable "skip_final_snapshot" {
  default = "true"
}

variable "username" {
  default = "postgres"
}

variable "max_allocated_storage" {
  default = "100"
}

variable "family" {
  default = "postgres13"
}
