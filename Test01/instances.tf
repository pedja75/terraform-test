data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "ec2_test01" {
  ami           = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.sg_test01.id}"]
  key_name = "Pedjini kljucevi"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.subnet1.id}"

  tags {
    Name = "EC2 instance Test01 by Terraform"
  }
}

resource "aws_instance" "ec2_test02" {
  ami           = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.sg_test01.id}"]
  key_name = "Pedjini kljucevi"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.subnet2.id}"

  tags {
    Name = "EC2 instance Test02 by Terraform"
  }
}

