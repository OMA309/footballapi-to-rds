resource "aws_vpc" "football_rds_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "football-rds"
  }
}

resource "aws_subnet" "football_rds_public_subnet_1" {
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
  vpc_id            = aws_vpc.football_rds_vpc.id

  tags = {
    Name = "football_rds-public_subnet_1"
  }
}

resource "aws_subnet" "football_rds_public_subnet_2" {
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1b"
  vpc_id            = aws_vpc.football_rds_vpc.id

  tags = {
    Name = "football_rds_public_subnet_2"
  }
}

resource "aws_internet_gateway" "football-rds-igw" {
  vpc_id = aws_vpc.football_rds_vpc.id

  tags = {
    Name = "football-rds-igw"
  }
}

resource "aws_route_table" "football_rds_rt" {
  vpc_id = aws_vpc.football_rds_vpc.id

  tags = {
    Name = "football_rds_rt"
  }
}

resource "aws_route" "football_rds_route" {
  route_table_id         = aws_route_table.football_rds_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.football-rds-igw.id
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.football_rds_public_subnet_1.id
  route_table_id = aws_route_table.football_rds_rt.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.football_rds_public_subnet_2.id
  route_table_id = aws_route_table.football_rds_rt.id
}

resource "aws_db_subnet_group" "football_rds_subnet_group" {
  name       = "football-rds-subnet-group"
  subnet_ids = [aws_subnet.football_rds_public_subnet_1.id, aws_subnet.football_rds_public_subnet_2.id]
}

resource "aws_ssm_parameter" "football_rds_db_username" {
  name  = "football_rds_db_username"
  type  = "String"
  value = "Botafli"
}

resource "aws_security_group" "football_rds_SG" {
  name        = "allow_traffic"
  description = "Allow inbound traffic and outbound"
  vpc_id      = aws_vpc.football_rds_vpc.id

  tags = {
    Name = "football-rds-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress_rule" {
  security_group_id = aws_security_group.football_rds_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "TCP"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "rds_egress_rule" {
  security_group_id = aws_security_group.football_rds_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports,allow all types of ip-protocol
}

resource "aws_db_instance" "football_db_instance" {
  allocated_storage    = 10
  db_name              = "footballdb"
  engine               = "postgres"
  engine_version       = "16.6"
  instance_class       = "db.r5.large"
  username             = aws_ssm_parameter.football_rds_db_username.value
  password             = aws_ssm_parameter.football_rds_db_password.value
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true
  publicly_accessible  = true
  db_subnet_group_name = aws_db_subnet_group.football_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.football_rds_SG.id]
}