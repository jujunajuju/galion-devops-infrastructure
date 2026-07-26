output "vpc_id" {

  description = "ID du VPC"

  value = aws_vpc.main.id

}


output "public_subnet_id" {

  description = "ID du subnet public"

  value = aws_subnet.public.id

}