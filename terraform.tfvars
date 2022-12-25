# Create variabls file (terraform.tfvars) for fetching subnets cidr
# app-subnet-public-vpc-custom = "10.0.1.0/24"
subnets_cidr = [ 
    {cidr_block="10.0.3.0/24", tag_name="test-app-subnet-public-vpc-custom"},
    {cidr_block="10.0.2.0/24", tag_name="dev-app-subnet-public-vpc-custom"}
] 
