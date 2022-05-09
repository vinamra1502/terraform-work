resource "aws_db_subnet_group" "postgresql" {
  description = "DB Subnet Group For postgres cluster"
  name       = "${var.name}-subnetgroup"
  subnet_ids = var.subnets
}
resource "aws_security_group" "postgresql" {
  name   = "${var.name}-securitygroup"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }
}

resource "random_password" "password" {
  length           = 12
  special          = false

}

resource "aws_db_parameter_group" "postgres" {
  name   = "${var.name}-parametergroup"
  family = var.family
}  

resource "aws_db_instance" "postgresql" {
   identifier                   = var.name
   engine                       = var.engine
   engine_version               = var.engine_version
   parameter_group_name         = aws_db_parameter_group.postgres.name
   auto_minor_version_upgrade   = var.auto_minor_version_upgrade
   instance_class               = var.instance_class
   allocated_storage            = var.allocated_storage
   vpc_security_group_ids       = [aws_security_group.postgresql.id]
   db_subnet_group_name         = aws_db_subnet_group.postgresql.name
   username                     = var.username
   password                     = random_password.password.result
   multi_az                     = var.multi_az
   skip_final_snapshot          = var.skip_final_snapshot
   max_allocated_storage        = var.max_allocated_storage

}
