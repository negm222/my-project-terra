profile  = "default"
region   = "us-east-1"

vpc_cidr = "10.0.0.0/16"

pub_subnet = [
    { subnets_cidr      = "10.0.0.0/24"
      availability_zone = "us-east-1a" },
    { subnets_cidr      = "10.0.2.0/24"
      availability_zone = "us-east-1b"}
]

priv_subnet = [
    { subnets_cidr      = "10.0.1.0/24"
      availability_zone = "us-east-1a"},
    { subnets_cidr      = "10.0.3.0/24"
     availability_zone  = "us-east-1b" }
]

lb_internal = [false,true]



