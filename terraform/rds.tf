resource "aws_db_instance" "movies_db" {
  allocated_storage      = 10
  identifier             = "movies-rds"
  db_name                = "movies"
  engine                 = "postgres"
  engine_version         = "14.5"
  instance_class         = "db.t3.micro"
  username               = "postgres"
  password               = "<Initial Password>"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.movies_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.movies_db_sg.id]
}

resource "aws_db_subnet_group" "movies_rds_subnet_group" {
  name       = "movies rds subnet group"
  subnet_ids = [aws_subnet.movies_private_subnet_1.id, aws_subnet.movies_private_subnet_2.id]

  tags = {
    Name = "Movies RDS subnet group"
  }
}

resource "aws_security_group" "movies_db_sg" {
  name        = "allow_psql"
  description = "Allow PSQL inbound traffic"
  vpc_id      = aws_vpc.movies_vpc.id

  ingress {
    description = "PSQL from User Home"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["<User IP>"]
  }

  ingress {
    description = "PSQL from public subnet 1"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    description = "PSQL from public subnet 2"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
