resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true # Important for public subnets

  tags = {
    Name = "${var.name_prefix}-public-subnet-${element(var.availability_zones, count.index)}-${random_id.vpc_id.hex}" #unique name
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.name_prefix}-private-subnet-${element(var.availability_zones, count.index)}-${random_id.vpc_id.hex}" #unique name
  }
}
