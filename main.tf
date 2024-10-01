provider "aws" {
  profile = var.profile
  region  = var.region
}

module "VPC" {
  source        = "./modules/VPC"
  vpc_cidr      = var.vpc_cidr
  nat_subnet_id = module.Subnet.public_subnets_id[0]
}

module "Subnet" {
  source       = "./modules/Subnet"
  vpc_id       = module.VPC.vpc_id
  pub_subnets  = var.pub_subnet
  priv_subnets = var.priv_subnet
  igw_id       = module.VPC.igw_id
  nat_id       = module.VPC.nat_id
}

module "LB" {
  source         = "./modules/Load_Balancer"
  lb_vpc_id      = module.VPC.vpc_id
  pub_target_id  = module.ec2.public_ec2_id
  priv_target_id = module.ec2.private_ec2_id
  lb_internal    = var.lb_internal
  lb_subnets     = [module.Subnet.public_subnets_id,module.Subnet.private_subnets_id]                   
  lb_sg_id       = module.ec2.security_group_id
}

module "ec2" {
  source                = "./modules/ec2"
  sg_vpc_id             = module.VPC.vpc_id
  priv_lb_dns           = module.LB.private_load_balancer_dns
  ec2_public_subnet_id  = module.Subnet.public_subnets_id
  ec2_private_subnet_id = module.Subnet.private_subnets_id
}

