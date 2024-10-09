resource "aws_internet_gateway" "sure_k8s_igw" {
  vpc_id = aws_vpc.sure_k8s_vpc.id

  tags = {
    Name = "sure-k8s-igw"
  }
}