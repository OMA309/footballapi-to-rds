resource "aws_s3_bucket" "api-to-rds" {
  bucket = "api-to-rds"
  force_destroy = true

  tags = {
    Name        = "football-api"
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "football_tfstate_file" { # bucket for the tfstate credentials
  bucket = "football-tfstate"
  force_destroy = true

  tags = {
    Name        = "tfstate-credential"
    Environment = "dev"
  }
}
