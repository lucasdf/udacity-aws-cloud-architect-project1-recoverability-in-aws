#!/usr/bin/env bash
set -euo pipefail
#set -x

source check_status.sh

version="0"
account_number=$(aws sts get-caller-identity | jq .Account --raw-output)
primary_region="us-east-1"
secondary_region="us-east-2"
# these should come from the script argument, a temporary env variable
# or use some AWS solution like AWS Secrets Manager
db_username=dbuser
db_password=dbpassword

echo "Starting script..."

# Primary VPC
echo "Setting up network"
network_stack_name="UdacityNetwork-$version"
primary_vpc_name="primary"
primary_cidr="10.1.0.0/16"
primary_stack_return=$(aws cloudformation create-stack \
  --region $primary_region \
  --stack-name $network_stack_name \
  --template-body file://./cloudformation/vpc.yaml \
  --parameters \
  ParameterKey=VpcName,ParameterValue=$primary_vpc_name \
  ParameterKey=VpcCIDR,ParameterValue=$primary_cidr)
echo "Primary VPC return: $primary_stack_return"

# Secondary VPC
secondary_vpc_name="secondary"
secondary_cidr="10.2.0.0/16"
PublicSubnet1CIDR="10.2.10.0/24"
PublicSubnet2CIDR="10.2.11.0/24"
PrivateSubnet1CIDR="10.2.20.0/24"
PrivateSubnet2CIDR="10.2.21.0/24"

secondary_stack_return=$(aws cloudformation create-stack \
  --region $secondary_region \
  --stack-name $network_stack_name \
  --template-body file://./cloudformation/vpc.yaml \
  --parameters \
  ParameterKey=VpcName,ParameterValue=$secondary_vpc_name \
  ParameterKey=VpcCIDR,ParameterValue=$secondary_cidr \
  ParameterKey=PublicSubnet1CIDR,ParameterValue=$PublicSubnet1CIDR \
  ParameterKey=PublicSubnet2CIDR,ParameterValue=$PublicSubnet2CIDR \
  ParameterKey=PrivateSubnet1CIDR,ParameterValue=$PrivateSubnet1CIDR \
  ParameterKey=PrivateSubnet2CIDR,ParameterValue=$PrivateSubnet2CIDR)
echo "Secondary VPC return: $secondary_stack_return"

verify_stack_creation $network_stack_name $primary_region
verify_stack_creation $network_stack_name $secondary_region

echo "Setting up network done!"
echo "Setting up rds"

# Primary RDS
primary_rds_name="udacity"
rds_stack_name="UdacityDB-$version"
database_name="udacity"
primary_rds_return=$(aws cloudformation create-stack --region $primary_region \
  --stack-name $rds_stack_name \
  --template-body file://./cloudformation/rds.yaml \
  --parameters \
  ParameterKey=VpcStackName,ParameterValue=$network_stack_name \
  ParameterKey=DBInstanceIdentifier,ParameterValue=$primary_rds_name \
  ParameterKey=DBName,ParameterValue=$database_name \
  ParameterKey=MasterUsername,ParameterValue=$db_username \
  ParameterKey=MasterPassword,ParameterValue=$db_password)
echo "Primary RDS return: $primary_rds_return"

verify_stack_creation $rds_stack_name $primary_region

# Secondary RDS (read replica)
primary_rds_arn="arn:aws:rds:$primary_region:$account_number:db:$primary_rds_name"
secondary_rds_name="udacity-secondary"
secondary_rds_return=$(aws cloudformation create-stack \
  --region $secondary_region \
  --stack-name $rds_stack_name \
  --template-body file://./cloudformation/rds_replica.yaml \
  --parameters \
  ParameterKey=VpcStackName,ParameterValue=$network_stack_name \
  ParameterKey=PrimaryRDSIdentifier,ParameterValue=$primary_rds_arn \
  ParameterKey=DBInstanceIdentifier,ParameterValue=$secondary_rds_name)
echo "Secondary RDS return: $secondary_rds_return"
echo "Setting up rds done!"
echo "Done!"
