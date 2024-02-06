output "azs" {
  value = data.aws_availability_zones.azs.names
} # to provide information to the end users, we must write output block to provide outputs so user can create resurces using these outputs info - here we writing output block to provide all AZ in east01 zone to the end users, we mentioned east-1 zone in provider.tf 

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  value = aws_subnet.database[*].id
}