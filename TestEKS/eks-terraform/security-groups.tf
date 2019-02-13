resource "aws_security_group" "k8s-eks-master-sg" {
  name        = "k8s-eks-master-sg"
  description = "SG for master control plane"
  vpc_id      = "${aws_vpc.k8s-eks-vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-eks-master-sg"
  }
}

resource "aws_security_group_rule" "k8s-eks-master-ingress-workstation-https" {
  cidr_blocks       = ["212.200.89.146/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.k8s-eks-master-sg.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "k8s-eks-master-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.k8s-eks-master-sg.id}"
  source_security_group_id = "${aws_security_group.k8s-eks-node-sg.id}"
  to_port                  = 443
  type                     = "ingress"
}


resource "aws_security_group" "k8s-eks-node-sg" {
  name        = "k8s-eks-node-sg"
  description = "SG for EKS worker nodes"
  vpc_id      = "${aws_vpc.k8s-eks-vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "k8s-eks-node",
     "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "k8s-eks-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.k8s-eks-node-sg.id}"
  source_security_group_id = "${aws_security_group.k8s-eks-node-sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "k8s-eks-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.k8s-eks-node-sg.id}"
  source_security_group_id = "${aws_security_group.k8s-eks-master-sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}
