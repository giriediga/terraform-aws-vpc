# Creating locals for keeping repeated variables within the locals.tf
# code for slice function to get first 2 AZs
 
locals {
  name = "${var.project_name}-${var.environment}"
  az_names = slice(data.aws_availability_zones.azs.names,0,2) # using slice function to get first 2 AZs
}