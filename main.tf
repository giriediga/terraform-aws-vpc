# using Data-source to fatch get the first 2 AZ
# code for creating VPC with tags, Internet Gateway & attach Int Gtw to VPC 
# Lab 1: -we are kept tags as optional in terraform-aws-vpc in main.tf n variable.tf . 
# Now lab2: we giving our own tags codes optional in terraform-aws-vpc in main.tf n variable.tf and in varibles.tf in vpc-test folder
# Now in lab3: code for creating Internet Gate way
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    var.common_tags, 
    var.vpc_tags,
    {
       # Name = "${var.project_name}-${var.environment}" # you can keep this code in Locals
        Name = local.name # we keeping above code in locals
    }
  )
}

# code for creating Internet Gate way
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
       # Name = "${var.project_name}-${var.environment}" # you can keep this code in Locals
       Name = local.name # we keeping above code in locals
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets_cidr[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.common_tags,
    var.public_subnets_tags,
    {
        Name = "${local.name}-public-${local.az_names[count.index]}"
    }
  )
}


resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnets_cidr[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.common_tags,
    var.private_subnets_tags,
    {
        Name = "${local.name}-private-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnets_cidr[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.common_tags,
    var.database_subnets_tags,
    {
        Name = "${local.name}-database-${local.az_names[count.index]}"
    }
  )
}

resource "aws_db_subnet_group" "default" {
  name       = "${local.name}"
  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name = "${local.name}"
  }
}

# code for creating Elastic IP
resource "aws_eip" "eip" {
  domain           = "vpc"
}

# code for creating NAT gateway, allocating elastic ip to it and keeping NAT in first public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id # 0 means first public subnet

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
        Name = "${local.name}"
    }
  )

#   # NAT gateway is depending on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}
  # code for creating Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
        Name = "${local.name}-public"
    }
  )
}
# code for creating Route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
    {
        Name = "${local.name}-private"
    }
  )
}
# code for creating Route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.database_route_table_tags,
    {
        Name = "${local.name}-database"
    }
  )
}
 # code for creating pulic route & attaching it & internet gateway to publice route table 
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id # To add public route to public route table  
  destination_cidr_block    = "0.0.0.0/0" # internet destination
  gateway_id = aws_internet_gateway.gw.id # adding internet gateway to public route table
}
# code for creating private route & attaching it & NAT gateway to private route table 
resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id # To add private route to private route table
  destination_cidr_block    = "0.0.0.0/0" # internet destination
  nat_gateway_id = aws_nat_gateway.main.id # adding NAT gateway to private route table
}
# code for creating database route & attaching it & NAT gateway to database route table 
resource "aws_route" "database_route" {
  route_table_id            = aws_route_table.database.id # To add database route to database route table
  destination_cidr_block    = "0.0.0.0/0" # internet destination
  nat_gateway_id = aws_nat_gateway.main.id # adding NAT gateway to database route table
}

# code for publice route table association with Public subnet
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets_cidr) # length function is to loop for our two public subnets
  subnet_id = element(aws_subnet.public[*].id, count.index)  # to slect public subnets
  route_table_id = aws_route_table.public.id #  public subnets will automatically associate to public route table
}
# code for private route table association with private subnet
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets_cidr)
  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}
# code for database route table association with databse subnet
resource "aws_route_table_association" "database" {
  count = length(var.database_subnets_cidr)
  subnet_id = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}