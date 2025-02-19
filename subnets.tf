# Dynamically fetch available Availability Zones in the selected region
data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count                   = min(length(var.public_subnets_cidr), length(data.aws_availability_zones.available.names))
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-subnet-${element(data.aws_availability_zones.available.names, count.index)}-${random_id.vpc_id.hex}"
  }
}

resource "aws_subnet" "private" {
  count             = min(length(var.private_subnets_cidr), length(data.aws_availability_zones.available.names))
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "${var.name_prefix}-private-subnet-${element(data.aws_availability_zones.available.names, count.index)}-${random_id.vpc_id.hex}"
  }
}
