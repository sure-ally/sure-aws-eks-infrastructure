resource "aws_route_table" "sure_k8s_private_route_table" {
  vpc_id = aws_vpc.sure_k8s_vpc.id

  route {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.sure_k8s_ngw.id
     
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "sure_k8s_public_route_table" {
  vpc_id = aws_vpc.sure_k8s_vpc.id

  route  {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.sure_k8s_igw.id
      
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "sure_k8s_private_route_table_assoc_ue1a" {
  subnet_id      = aws_subnet.private_us_east_1a.id
  route_table_id = aws_route_table.sure_k8s_private_route_table.id
}

resource "aws_route_table_association" "sure_k8s_private_route_table_assoc_ue1b" {
  subnet_id      = aws_subnet.private_us_east_1b.id
  route_table_id = aws_route_table.sure_k8s_private_route_table.id
}

resource "aws_route_table_association" "sure_k8s_public_route_table_assoc_ue1a" {
  subnet_id      = aws_subnet.public_us_east_1a.id
  route_table_id = aws_route_table.sure_k8s_public_route_table.id
}

resource "aws_route_table_association" "sure_k8s_public_route_table_assoc_ue1b" {
  subnet_id      = aws_subnet.public_us_east_1b.id
  route_table_id = aws_route_table.sure_k8s_public_route_table.id
}
