variable "sg_vpc_id"{
  type = string
}
variable "priv_lb_dns" {} 
variable "ec2_public_subnet_id" {
  type = list
}
variable "ec2_private_subnet_id" {
  type = list
}
variable "ec2_html" {
  type    = list(string)
  default = [
   "Welcome to Private EC2 Instance 1",   
   "Welcome to Private EC2 Instance 2"   
  ]
}
variable "key_pair_name" {
  description = "Name of the EC2 Key Pair"
  type        = string
  default = "Nehmkey"
}
