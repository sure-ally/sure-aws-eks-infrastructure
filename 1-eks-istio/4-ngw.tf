resource "aws_eip" "sure_k8s_ngw_eip" {
  # domain = "vpc"
  # vpc = true

  tags = {
    Name = "sure-k8s-ngw-eip"
  }
}

resource "aws_nat_gateway" "sure_k8s_ngw" {
  allocation_id = aws_eip.sure_k8s_ngw_eip.id
  subnet_id     = aws_subnet.public_us_east_1a.id

  tags = {
    Name = "sure-k8s-ngw"
  }

  depends_on = [aws_internet_gateway.sure_k8s_igw]
}
