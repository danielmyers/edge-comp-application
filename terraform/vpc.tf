resource "aws_vpc" "movies_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "movies_vpc"
  }
}

resource "aws_subnet" "movies_public_subnet_1" {
  vpc_id            = aws_vpc.movies_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "movies-public-subnet-1"
  }
}

resource "aws_subnet" "movies_public_subnet_2" {
  vpc_id            = aws_vpc.movies_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "movies-public-subnet-2"
  }
}

resource "aws_subnet" "movies_private_subnet_1" {
  vpc_id            = aws_vpc.movies_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "movies-private-subnet-1"
  }
}

resource "aws_subnet" "movies_private_subnet_2" {
  vpc_id            = aws_vpc.movies_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "movies-private-subnet-2"
  }
}

resource "aws_internet_gateway" "movies_vpc_ig" {
  vpc_id = aws_vpc.movies_vpc.id

  tags = {
    Name = "Movies VPC Internet Gateway"
  }
}

resource "aws_route_table" "movies_vpc_rt" {
  vpc_id = aws_vpc.movies_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.movies_vpc_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.movies_vpc_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "movies_vpc_private_rt" {
  vpc_id = aws_vpc.movies_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.movies_nat_gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.movies_vpc_ig.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "movies_rt_public_1_assoc" {
  subnet_id      = aws_subnet.movies_public_subnet_1.id
  route_table_id = aws_route_table.movies_vpc_rt.id
}

resource "aws_route_table_association" "movies_rt_public_2_assoc" {
  subnet_id      = aws_subnet.movies_public_subnet_2.id
  route_table_id = aws_route_table.movies_vpc_rt.id
}

resource "aws_route_table_association" "movies_rt_private_1_assoc" {
  subnet_id      = aws_subnet.movies_private_subnet_1.id
  route_table_id = aws_route_table.movies_vpc_private_rt.id
}

resource "aws_route_table_association" "movies_rt_private_2_assoc" {
  subnet_id      = aws_subnet.movies_private_subnet_2.id
  route_table_id = aws_route_table.movies_vpc_private_rt.id
}


resource "aws_eip" "movies_nat_gateway_eip" {
  vpc = true
}

resource "aws_nat_gateway" "movies_nat_gateway" {
  allocation_id = aws_eip.movies_nat_gateway_eip.id
  subnet_id     = aws_subnet.movies_public_subnet_1.id

  tags = {
    Name = "Movies NAT Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.movies_vpc_ig]
}