variable "public1_prefix" {
  default = "sv-public1"
}

resource "aws_key_pair" "public1" {
  key_name   = var.public1_prefix
  public_key = var.public1_public_key
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "main" {
  cidr_block = "172.26.0.0/16"

  enable_dns_hostnames = true

  enable_dns_support = true

  tags = {
    Name = var.public1_prefix
  }
}

resource "aws_subnet" "main" {
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 3, 1)}"

  vpc_id = "${aws_vpc.main.id}"

  availability_zone = var.aws_az

  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = var.public1_prefix
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags = {
    Name = var.public1_prefix
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_security_group" "main" {
  name = "externalssh"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "externalssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.main.id}"
}

resource "aws_security_group_rule" "p2p" {
  type            = "ingress"
  from_port       = 30333
  to_port         = 30333
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.main.id}"
}

resource "aws_security_group_rule" "allow_all" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.main.id}"
}

resource "aws_instance" "main" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = var.aws_machine_type
  key_name      = var.public1_prefix

  subnet_id              = "${aws_subnet.main.id}"
  vpc_security_group_ids = ["${aws_security_group.main.id}"]

  tags = {
    Name = var.public1_prefix
  }
}
