# Data-source: using a data source, fetch az from AWS.
# Slice Function: using Slice function you can get the first 2 AZ.
data "aws_availability_zones" "azs" {
    # above code to get all_availability_zones = true
    state = "available"
}

data "aws_vpc" "default" {
  default = true
}

# data source
data "aws_route_table" "default" {
    vpc_id = data.aws_vpc.default.id
    filter {
        name = "association.main"
        values = ["true"]
    }
}