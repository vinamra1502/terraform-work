
variable "environment" {
  default = "dev"
}
variable "vpc_id" {
  default = ""
}
variable "subnet_ids" {
  type    = list(string)
  default = []
}
