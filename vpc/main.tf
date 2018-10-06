data aws_availability_zones "available" {}

resource aws_vpc "vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "${var.env}-${var.vpc_basename}"
  }
}

resource aws_subnet "subn" {
  count             = "${var.az_count}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.vpc.id}"

  tags {
    Env  = "${var.env}"
    Name = "${var.env}-${var.vpc_basename}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource aws_internet_gateway "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.env}_${var.vpc_basename}_gateway"
  }
}

resource aws_route_table "rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource aws_route_table_association "rta" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.subn.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt.id}"
}
