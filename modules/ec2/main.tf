data "aws_ami" "ami_id" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  } 
  }
resource "aws_security_group" "sg" {
  vpc_id = var.sg_vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sg"
  }
}

resource "aws_instance" "pub-ec2" {
  count                       = length(var.ec2_public_subnet_id) 
  ami                         = data.aws_ami.ami_id.id
  instance_type               = "t2.micro"
  subnet_id                   = var.ec2_public_subnet_id[count.index]    
  security_groups             = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name  
  
  tags = {
      Name = "public_ec2_${count.index}"
    } 

 provisioner "remote-exec" {
  inline = [
    "set -e",   
    "sleep 10",
    "sudo yum update -y",
    "sudo yum install -y httpd",
    "sudo systemctl start httpd",
    "sudo systemctl enable httpd",
     <<-EOT
    echo '<html><body><h1>Welcome to Public Ahmed Negm EC2 Instance ${count.index}</h1>
    </body></html>' | sudo tee /var/www/html/index.html
    EOT
    ]
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("~/Downloads/Nehmkey.pem")
    timeout     = "5m"
  }
}
  
  provisioner "local-exec" {
    when        = create
    on_failure  = continue
    command = "echo public-ip-${count.index} : ${self.public_ip} >> all-ips.txt"
  }
}


resource "aws_instance" "priv-ec2" {
  count                       = length(var.ec2_private_subnet_id)
  ami                         = data.aws_ami.ami_id.id
  instance_type               = "t2.micro"
  subnet_id                   = var.ec2_private_subnet_id[count.index]
  security_groups             = [aws_security_group.sg.id]
  associate_public_ip_address = false
 lifecycle {
        create_before_destroy = true
    }
  tags = {
    Name = "private_ec2_${count.index}"
  }

  user_data = <<EOF
              #!/bin/bash
              sleep 10
              sudo yum update -y
              sleep 10
              sudo yum install -y httpd
              sleep 10
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<html><body><h1>${var.ec2_html[count.index]}</h1>
              <p>welcome to Priv${count.index} </p>
              </body></html>" | sudo tee /var/www/html/index.html
              sudo systemctl restart httpd
              EOF


  provisioner "local-exec" {
    when        = create
    on_failure  = continue
    command = "echo private-ip-${count.index} : ${self.private_ip} >> all-ips.txt"
  }
}
