data "aws_ami" "k8s-eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.k8s-eks.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

locals {
  k8s-eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.k8s-eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.k8s-eks.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "k8s-eks-node-launch-config" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.k8s-eks-node.name}"
  image_id                    = "${data.aws_ami.k8s-eks-worker.id}"
  instance_type               = "t3.medium"
  name_prefix                 = "k8s-eks-worker"
  security_groups             = ["${aws_security_group.k8s-eks-node-sg.id}"]
  user_data_base64            = "${base64encode(local.k8s-eks-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "k8s-eks-node-asg" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.k8s-eks-node-launch-config.id}"
  max_size             = 2
  min_size             = 1
  name                 = "k8s-eks-node-asg"
  vpc_zone_identifier  = ["${aws_subnet.k8s-eks-subnet.*.id}"]

  tag {
    key                 = "Name"
    value               = "k8s-eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
