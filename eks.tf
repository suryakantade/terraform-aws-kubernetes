resource "aws_eks_cluster" "eks" {
  name     = "eks"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config { subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id] }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn

  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  instance_types = ["t3.small"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry,
  ]
}

