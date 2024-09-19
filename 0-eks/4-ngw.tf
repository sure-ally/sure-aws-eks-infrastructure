resource "aws_eip" "surek8sngweip" {
  # domain = "vpc"
  # vpc = true

  tags = {
    Name = "sure-k8s-ngw-eip"
  }
}

resource "aws_nat_gateway" "surek8sngw" {
  allocation_id = aws_eip.surek8sngweip.id
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = {
    Name = "sure-k8s-ngw"
  }

  depends_on = [aws_internet_gateway.surek8sigw]
}
