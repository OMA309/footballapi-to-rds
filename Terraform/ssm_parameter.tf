resource "random_password" "password" {
  length  = 10
  special = false
}

resource "aws_ssm_parameter" "football_rds_db_password" {
  name  = "football_rds_db_password"
  type  = "String"
  value = random_password.password.result
}

