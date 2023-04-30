data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_key_pair" "nku_key_pair" {
  key_name = "<Key Pair Name>"
}

resource "aws_instance" "movies_application" {
  ami                  = "ami-07a72d328538fc075"
  instance_type        = "t3.micro"
  subnet_id            = aws_subnet.movies_public_subnet_1.id
  iam_instance_profile = aws_iam_instance_profile.movies_instance_profile.name
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_web.id,
    aws_security_group.movies_ec2_instance_sg.id
  ]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.nku_key_pair.key_name

  tags = {
    Name = "Movies App"
  }
}

resource "aws_iam_instance_profile" "movies_instance_profile" {
  name = "movies_instance_profile"
  role = aws_iam_role.movies_instance_role.name
}

resource "aws_eip" "movies_instance_eip" {
  instance = aws_instance.movies_application.id
  vpc      = true
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic from administrator"
  vpc_id      = aws_vpc.movies_vpc.id

  ingress {
    description = "TLS from Clients"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["<User IP>"]
  }

  ingress {
    description = "HTTP from Clients"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["<User IP>"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.movies_vpc.id

  ingress {
    description = "TLS from Clients"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<User IP>"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "movies_ec2_instance_sg" {
  name        = "movies_ec2_instance_sg"
  description = "Security group for Movies EC2 instance"
  vpc_id      = aws_vpc.movies_vpc.id

  ingress {
    description     = "Load Balancer Connections"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.movies_lb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_lb" "movies_load_balancer" {
  name               = "movies-load-balancer"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.movies_lb_sg.id]
  subnets         = [aws_subnet.movies_public_subnet_1.id, aws_subnet.movies_public_subnet_2.id]

  tags = {
    Project = "movies"
  }
}

resource "aws_lb_listener" "movies_web_tls_listener" {
  load_balancer_arn = aws_lb.movies_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.nkuproject_acm_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.movies_alb_tg.arn
  }
}

resource "aws_lb_listener" "movies_web_http_listener" {
  load_balancer_arn = aws_lb.movies_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_security_group" "movies_lb_sg" {
  name        = "movies_lb_sg"
  description = "Security group for the movies ALB"
  vpc_id      = aws_vpc.movies_vpc.id

  ingress {
    description = "TLS from Clients"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from Clients"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "movies_lb_sg"
  }
}

resource "aws_lb_target_group" "movies_alb_tg" {
  name     = "movies-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.movies_vpc.id

  health_check {
    healthy_threshold   = 2
    interval            = 15
    path                = "/"
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "movies_tg_attachment" {
  target_group_arn = aws_lb_target_group.movies_alb_tg.arn
  target_id        = aws_instance.movies_application.id
  port             = 80
}