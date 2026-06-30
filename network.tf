data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.test_netzwerk.id

  tags = {
    Name = "MeinCachyOSTestIGW"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.test_netzwerk.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "MeinCachyOSTestPublicSubnet"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.test_netzwerk.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "MeinCachyOSTestPrivateSubnetA"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.test_netzwerk.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "MeinCachyOSTestPrivateSubnetB"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.test_netzwerk.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "MeinCachyOSTestPublicRouteTable"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
