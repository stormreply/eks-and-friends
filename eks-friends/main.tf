###### Set the used terraform version ######
terraform {
  required_version = ">= 0.12.0"
}

###### Define the provider, could be also something like gcp or so ######
provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

###### requests the availability zones in your chosen region ######
data "aws_availability_zones" "available" {
}

###### create the security group for the first worker group ######
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

###### create the security group for the second worker group ######
resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

###### create the general security group for all worker groups ######
resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

###### this module will create the virtual private cloud ######
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"

  name                 = "labcamp-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  ###### this flag is important without EKS will not be able to create a cluster ######
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.clustername}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.clustername}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.clustername}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

###### this module will create the EKS cluster ######
module "eks" {
  #source       = "terraform-aws-modules/eks/aws"
  source        = "../eks-terraform"
  cluster_name = var.clustername
  subnets      = module.vpc.private_subnets
  cluster_version      = var.cluster_version

  tags = {
    Environment = "labcamp"
    GithubRepo  = "storm-reply"
    Owner   = var.yourname
  }
  ###### takes the VPC ID from the before generated VPC ######
  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.small"
      #additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t3.small"
      #additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]
 
  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts
  #there is currently a bug thats why we need this wildcard for windows ami even if we don't use it
  worker_ami_name_filter_windows          = "*"
  #cluster_endpoint_private_access      = "true" 
  #cluster_endpoint_public_access       = "false"
  #cluster_enabled_log_types            = "api","audit","authenticator","controllerManager","scheduler"

}