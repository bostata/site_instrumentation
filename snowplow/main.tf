# ------------------------------------------------------------------------------
# Operator User and IAM
# ------------------------------------------------------------------------------
resource "aws_iam_user" "operator" {
  name = "${var.env}-${var.snowplow_system_tag}-operator"
}

resource "aws_iam_access_key" "operator_key" {
  user = "${aws_iam_user.operator.name}"
}

resource "aws_iam_user_policy" "operator_policy" {
  name = "${var.env}-${var.department}-${var.snowplow_system_tag}-operator-iam-policy"
  user = "${aws_iam_user.operator.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "kinesis:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "dynamodb:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "cloudwatch:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "firehose:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

# ------------------------------------------------------------------------------
# Load Balancer
# ------------------------------------------------------------------------------

resource aws_security_group "lb_sg" {
  description = "Access control to the load balancer"

  vpc_id = "${var.vpc_id}"
  name   = "${var.env}-${var.department}-${var.snowplow_system_tag}-lb-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_alb "alb" {
  name    = "${var.env}-${var.department}-${var.snowplow_system_tag}-alb" # Can only hyphenate
  subnets = ["${var.subnets}"]

  security_groups = [
    "${aws_security_group.lb_sg.id}",
  ]
}

resource aws_alb_target_group "alb_target_grp" {
  name     = "${var.env}-${var.department}-${var.snowplow_system_tag}-lb-tg" # Can only hyphenate
  vpc_id   = "${var.vpc_id}"
  protocol = "${var.snowplow_lb_target_group_protocol}"
  port     = "${var.snowplow_collector_ingress_port}"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = true
  }

  health_check {
    healthy_threshold   = "${var.snowplow_lb_healthy_threshold}"
    unhealthy_threshold = "${var.snowplow_lb_unhealthy_threshold}"
    timeout             = "${var.snowplow_lb_health_timeout}"
    interval            = "${var.snowplow_lb_health_interval}"
    path                = "${var.snowplow_lb_health_path}"
    port                = "${var.snowplow_collector_ingress_port}"
  }
}

resource aws_alb_listener "alb_listener" {
  load_balancer_arn = "${aws_alb.alb.id}"
  protocol          = "${var.snowplow_lb_protocol}"
  port              = "${var.snowplow_lb_port}"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_grp.id}"
    type             = "forward"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource aws_kinesis_stream "collector_good" {
  name             = "${var.env}-${var.department}-${var.snowplow_system_tag}-${var.snowplow_collector_good_stream}"
  shard_count      = "${var.snowplow_collector_good_shard_count}"
  retention_period = "${var.snowplow_collector_good_retention_hours}"

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags {
    Env        = "${var.env}"
    Department = "${var.department}"
    System     = "${var.snowplow_system_tag}"
    Name       = "${var.env}-${var.department}-${var.snowplow_system_tag}-${var.snowplow_collector_good_stream}"
  }
}

resource aws_kinesis_stream "collector_bad" {
  name             = "${var.env}-${var.department}-${var.snowplow_system_tag}-${var.snowplow_collector_bad_stream}"
  shard_count      = "${var.snowplow_collector_bad_shard_count}"
  retention_period = "${var.snowplow_collector_bad_retention_hours}"

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags {
    Env        = "${var.env}"
    Department = "${var.department}"
    System     = "${var.snowplow_system_tag}"
    Name       = "${var.env}-${var.department}-${var.snowplow_system_tag}-${var.snowplow_collector_bad_stream}"
  }
}

# ------------------------------------------------------------------------------
# Collectors
# ------------------------------------------------------------------------------

resource aws_security_group "instance_http_sg" {
  description = "Access control for instances that listen on http port"

  vpc_id = "${var.vpc_id}"
  name   = "${var.env}-${var.department}-${var.snowplow_system_tag}-http"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${chomp(var.my_ip)}/32"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = "${var.snowplow_collector_ingress_port}"
    to_port     = "${var.snowplow_collector_ingress_port}"
    cidr_blocks = ["${chomp(var.my_ip)}/32"]               # USE BASTION OR SOMETHING - NOT IP
  }

  ingress {
    protocol    = "tcp"
    from_port   = 9100
    to_port     = 9100
    cidr_blocks = ["${chomp(var.my_ip)}/32"] # USE BASTION OR SOMETHING - NOT IP
  }

  ingress {
    protocol  = "tcp"
    from_port = "${var.snowplow_collector_ingress_port}"
    to_port   = "${var.snowplow_collector_ingress_port}"

    security_groups = [
      "${aws_security_group.lb_sg.id}",
    ]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data template_file "collector_cloud_config" {
  template = "${file("${path.module}/files/collector-cloud-config.tpl")}"

  vars {
    env                             = "${var.env}"
    department                      = "${var.department}"
    snowplow_system_tag             = "${var.snowplow_system_tag}"
    snowplow_collector_version      = "${var.snowplow_collector_version}"
    snowplow_collector_ingress_port = "${var.snowplow_collector_ingress_port}"
    snowplow_collector_good_stream  = "${var.snowplow_collector_good_stream}"
    snowplow_collector_bad_stream   = "${var.snowplow_collector_bad_stream}"
    aws_region                      = "${var.aws_region}"
    operator_access_key_id          = "${aws_iam_access_key.operator_key.id}"
    operator_secret_access_key      = "${aws_iam_access_key.operator_key.secret}"
    snowplow_home                   = "${var.snowplow_home}"
    snowplow_service_user           = "${var.snowplow_service_user}"
    snowplow_service_group          = "${var.snowplow_service_group}"
  }
}

resource aws_instance "collector" {
  ami                         = "${var.snowplow_collector_ami_id}"
  instance_type               = "${var.snowplow_collector_instance_class}"
  count                       = "${var.snowplow_collector_node_count}"
  subnet_id                   = "${element(var.subnets, count.index)}"
  vpc_security_group_ids      = ["${aws_security_group.instance_http_sg.id}"]
  associate_public_ip_address = true
  key_name                    = "${var.snowplow_ec2_keypair}"
  user_data                   = "${data.template_file.collector_cloud_config.rendered}"

  root_block_device {
    volume_size = "${var.snowplow_collector_root_block_size_gigs}"
  }

  tags {
    Name       = "${var.env}-${var.department}-${var.snowplow_system_tag}-collector-${count.index + 1}"
    Department = "${var.department}"
    Env        = "${var.env}"
    System     = "${var.snowplow_system_tag}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource aws_eip "collector_eip" {
  count    = "${var.snowplow_collector_node_count}"
  instance = "${element(aws_instance.collector.*.id, count.index)}"

  tags {
    Name       = "${var.env}-${var.department}-${var.snowplow_system_tag}-collector-${count.index + 1}-eip"
    Department = "${var.department}"
    Env        = "${var.env}"
    System     = "${var.snowplow_system_tag}"
  }
}

resource aws_alb_target_group_attachment "collector_alb_attachment" {
  count            = "${var.snowplow_collector_node_count}"
  target_group_arn = "${aws_alb_target_group.alb_target_grp.arn}"
  target_id        = "${element(aws_instance.collector.*.id, count.index)}"
  port             = "${var.snowplow_collector_ingress_port}"
}

# ------------------------------------------------------------------------------
# Enricher
# ------------------------------------------------------------------------------

resource aws_kinesis_stream "enricher_good" {
  name             = "${var.env}-${var.department}-${var.snowplow_system_tag}-${var.snowplow_enricher_good_stream}"
  shard_count      = "${var.snowplow_enricher_good_shard_count}"
  retention_period = "${var.snowplow_enricher_good_retention_hours}"

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags {
    Env        = "${var.env}"
    Department = "${var.department}"
    System     = "${var.snowplow_system_tag}"
    Name       = "${var.env}-${var.department}-${var.snowplow_system_tag}-${var.snowplow_enricher_good_stream}"
  }
}

resource aws_kinesis_stream "enricher_bad" {
  name             = "${var.env}-${var.department}-${var.snowplow_system_tag}-${var.snowplow_enricher_bad_stream}"
  shard_count      = "${var.snowplow_enricher_bad_shard_count}"
  retention_period = "${var.snowplow_enricher_bad_retention_hours}"

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags {
    Env        = "${var.env}"
    Department = "${var.department}"
    System     = "${var.snowplow_system_tag}"
    Name       = "${var.env}-${var.department}-${var.snowplow_system_tag}-${var.snowplow_enricher_bad_stream}"
  }
}

resource aws_kinesis_stream "enricher_pii" {
  name             = "${var.env}-${var.department}-${var.snowplow_system_tag}-${var.snowplow_enricher_pii_stream}"
  shard_count      = "${var.snowplow_enricher_pii_shard_count}"
  retention_period = "${var.snowplow_enricher_pii_retention_hours}"

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags {
    Env        = "${var.env}"
    Department = "${var.department}"
    System     = "${var.snowplow_system_tag}"
    Name       = "${var.env}-${var.department}-${var.snowplow_system_tag}-${var.snowplow_enricher_pii_stream}"
  }
}

resource aws_dynamodb_table "enricher_checkpoint" {
  name           = "${var.env}-${var.department}-${var.snowplow_enricher_checkpoint_table}"
  read_capacity  = "${var.snowplow_enricher_checkpoint_write_capacity}"
  write_capacity = "${var.snowplow_enricher_checkpoint_read_capacity}"
  hash_key       = "leaseKey"

  attribute {
    name = "leaseKey"
    type = "S"
  }

  tags {
    Env        = "${var.env}"
    Department = "${var.department}"
    System     = "${var.snowplow_system_tag}"
  }
}

resource aws_security_group "instance_no_http_sg" {
  description = "Access control for instances that do not listen on any http port"

  vpc_id = "${var.vpc_id}"
  name   = "${var.env}-${var.department}-${var.snowplow_system_tag}-no-http"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${chomp(var.my_ip)}/32"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 9100
    to_port     = 9100
    cidr_blocks = ["${chomp(var.my_ip)}/32"] # USE BASTION OR SOMETHING - NOT IP
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data template_file "enricher_cloud_config" {
  template = "${file("${path.module}/files/enricher-cloud-config.tpl")}"

  vars {
    env                                = "${var.env}"
    department                         = "${var.department}"
    primary_domain                     = "${var.primary_domain}"
    snowplow_system_tag                = "${var.snowplow_system_tag}"
    snowplow_enricher_version          = "${var.snowplow_enricher_version}"
    snowplow_collector_good_stream     = "${var.snowplow_collector_good_stream}"
    snowplow_enricher_good_stream      = "${var.snowplow_enricher_good_stream}"
    snowplow_enricher_bad_stream       = "${var.snowplow_enricher_bad_stream}"
    snowplow_enricher_pii_stream       = "${var.snowplow_enricher_pii_stream}"
    snowplow_enricher_checkpoint_table = "${var.snowplow_enricher_checkpoint_table}"
    aws_region                         = "${var.aws_region}"
    operator_access_key_id             = "${aws_iam_access_key.operator_key.id}"
    operator_secret_access_key         = "${aws_iam_access_key.operator_key.secret}"
    snowplow_home                      = "${var.snowplow_home}"
    snowplow_service_user              = "${var.snowplow_service_user}"
    snowplow_service_group             = "${var.snowplow_service_group}"
  }
}

resource aws_instance "enricher" {
  ami           = "${var.snowplow_enricher_ami_id}"
  instance_type = "${var.snowplow_enricher_instance_class}"
  count         = "${var.snowplow_enricher_node_count}"

  subnet_id                   = "${element(var.subnets, count.index)}"
  vpc_security_group_ids      = ["${aws_security_group.instance_no_http_sg.id}"]
  associate_public_ip_address = true
  key_name                    = "${var.snowplow_ec2_keypair}"
  user_data                   = "${data.template_file.enricher_cloud_config.rendered}"

  root_block_device {
    volume_size = "${var.snowplow_enricher_root_block_size_gigs}"
  }

  tags {
    Env        = "${var.env}"
    Department = "${var.department}"
    System     = "${var.snowplow_system_tag}"
    Name       = "${var.env}-${var.department}-${var.snowplow_system_tag}-enricher-${count.index + 1}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource aws_s3_bucket "delivery_bucket" {
  bucket = "${var.env}-${var.department}-${var.snowplow_system_tag}-${var.snowplow_sink_good_s3_bucket}"
  acl    = "private"
}

# resource "aws_iam_role" "kinesis_role" {
#   name = "${var.env}-${var.department}-${var.snowplow_system_tag}-operator-role"


#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "firehose.amazonaws.com"
#       },
#       "Effect": "Allow"
#     },
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "kinesisanalytics.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     },
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "s3.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }


# resource aws_kinesis_firehose_delivery_stream "delivery_stream" {
#   name        = "${var.env}-${var.department}-${var.snowplow_system_tag}-delivery"
#   destination = "extended_s3"


#   kinesis_source_configuration {
#     role_arn           = "${aws_iam_role.kinesis_role.arn}"
#     kinesis_stream_arn = "${aws_kinesis_stream.enricher_good.arn}"
#   }


#   extended_s3_configuration {
#     role_arn        = "${aws_iam_role.kinesis_role.arn}"
#     bucket_arn      = "${aws_s3_bucket.delivery_bucket.arn}"
#     buffer_size     = 1
#     buffer_interval = 60
#   }
# }

