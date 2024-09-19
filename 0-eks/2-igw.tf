resource "aws_internet_gateway" "surek8sigw" {
  vpc_id = aws_vpc.surek8svpc.id

  tags = {
    Name = "sure-k8s-igw"
  }
}