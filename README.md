# udacity-aws-cloud-architect-project1-recoverability-in-aws

## Relational Database Resilience

### SWBAT build networks that will continue to operate through the loss of a single data center

Primary VPC located in us-east-1:
![primary vpc](./images/primary_vpc.png)
![primary vpc subnets](./images/primary_vpc_subnets.png)

Secondary VPC located in us-east-2:
![secondary vpc](./images/secondary_vpc.png)
![secondary vpc subnets](./images/secondary_vpc_subnets.png)

### SWBAT build systems that align to a business availability objectives for redundancy.
The primary DB is running in us-east-1. It is running on subnets "06d" and "0a5", which are thw two private subnets.
![primary db](./images/primary_db_config.png)

These are the private subnets route tables. Traffic is restricted.
![primary private subnet 1](./images/primary_private_subnet_1.png)
![primary private subnet 2](./images/primary_private_subnet_2.png)

Automated backup is configured once a day:
![primary db backup](./images/primary_db_config_2.png)

### SWBAT build systems that align to business availability objectives for resiliency.
The secondary DB is running in us-east-2.
![primary db config](./images/primary_db_config.png)

It is configured as a read replica from the primary DB.
![primary db config 2](./images/primary_db_config_2.png)

These are the private subnets route tables. Traffic is restricted.
![secondary private subnet 1](./images/secondary_private_subnet_1.png)
![secondary private subnet 2](./images/secondary_private_subnet_2.png)

