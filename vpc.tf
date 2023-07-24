# Create a VPC
resource "aws_vpc" "vpc1" {
  cidr_block = "10.1.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name        = "dev"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1a"

  tags = {
    Name        = "dev-public"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_internet_gateway" "vpc1_internet_gateway" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name        = "dev-igw"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_route_table" "vpc1_public_rt" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name        = "dev_public_rt"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.vpc1_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc1_internet_gateway.id

}

resource "aws_route_table_association" "vpc1_public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.vpc1_public_rt.id

}

resource "aws_security_group" "vpc1_public_sg" {
  name        = "vpc1-public-sg"
  description = "allows all traffic access to pubic subnet from home network"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["24.4.99.164/32"] #remember to add home IP.
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["24.4.99.164/32"] #remember to change
  }
}

resource "aws_key_pair" "vpc1_auth" {
  key_name   = "terraform1"
  public_key = file("~/.ssh/terraform1.pub")

}

resource "aws_instance" "dev_srv" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.vpc1_auth.id
  vpc_security_group_ids = [aws_security_group.vpc1_public_sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  user_data = file("userdata.tpl")
  
  #root_block_device {
  #volume_size = WHATEVER
  #}

  tags = {
    Name        = "dev_srv"
    Terraform   = "true"
    Environment = "dev"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname = self.public_ip,
      user = "ubuntu",
      identityfile = "~/.ssh/terraform1"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }
}