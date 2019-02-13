resource "aws_vpc" "k8s-eks-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "k8s-eks-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "k8s-eks-subnet" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.k8s-eks-vpc.id}"

  tags = "${
    map(
     "Name", "k8s-eks-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "k8s-eks-igw" {
  vpc_id = "${aws_vpc.k8s-eks-vpc.id}"

  tags = {
    Name = "k8s-eks-igw"
  }
}

resource "aws_route_table" "k8s-eks-rt" {
  vpc_id = "${aws_vpc.k8s-eks-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.k8s-eks-igw.id}"
  }
}

resource "aws_route_table_association" "k8s-eks-rt-ass" {
  count = 2

  subnet_id      = "${aws_subnet.k8s-eks-subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.k8s-eks-rt.id}"
}
