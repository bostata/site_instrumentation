output "vpc_arn" {
  value = "${aws_vpc.vpc.arn}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "subnets" {
  value = ["${aws_subnet.subn.*.id}"]
}
