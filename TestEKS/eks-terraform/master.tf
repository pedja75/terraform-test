resource "aws_eks_cluster" "k8s-eks" {
  name            = "${var.cluster-name}"
  role_arn        = "${aws_iam_role.k8s-eks-iam-role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.k8s-eks-master-sg.id}"]
    subnet_ids         = ["${aws_subnet.k8s-eks-subnet.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.k8s-eks-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.k8s-eks-AmazonEKSServicePolicy",
  ]
}
