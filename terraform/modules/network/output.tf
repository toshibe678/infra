output "aws_vpc_toshi-root-default-vpc_id" {
  value = "${aws_vpc.toshi-root-default-vpc.id}"
}

output "aws_subnet_subnet-apne1-az2_id" {
  value = "${aws_subnet.subnet-apne1-az2.id}"
}

output "aws_subnet_subnet-apne1-az1_id" {
  value = "${aws_subnet.subnet-apne1-az1.id}"
}

output "aws_subnet_subnet-apne1-az4_id" {
  value = "${aws_subnet.subnet-apne1-az4.id}"
}

output "aws_internet_gateway_igw_toshi-root_id" {
  value = "${aws_internet_gateway.igw_toshi-root.id}"
}

output "aws_main_route_table_association_toshi-root-default-vpc_id" {
  value = "${aws_main_route_table_association.toshi-root-default-vpc.id}"
}

output "aws_route_table_rtb_toshi_root_igw_id" {
  value = "${aws_route_table.rtb_toshi_root_igw.id}"
}

output "aws_security_group_staging_sg_id" {
  value = "${aws_security_group.staging_sg.id}"
}
