# ---------------------------------------------------------
# Generic
# ---------------------------------------------------------
env                                             = "prod"
department                                      = "bostata"
primary_domain                                  = "bostata.com"
aws_region                                      = "us-east-1"
az_count                                        = 2
# ---------------------------------------------------------
# VPC
# ---------------------------------------------------------
vpc_cidr                                        = "10.0.0.0/16"
vpc_basename                                    = "infra"
# ---------------------------------------------------------
# Snowplow Infrastructure
# ---------------------------------------------------------
snowplow_system_tag                             = "sp"
snowplow_ec2_keypair                            = "snowplow_prod"
snowplow_ec2_keypair_path                       = "snowplow_prod.pem"
# Load balancing
snowplow_lb_port                                = 80
snowplow_lb_protocol                            = "HTTP"
snowplow_lb_target_group_protocol               = "HTTP"
snowplow_lb_health_path                         = "/health"
snowplow_lb_healthy_threshold                   = 2
snowplow_lb_unhealthy_threshold                 = 2
snowplow_lb_health_timeout                      = 3
snowplow_lb_health_interval                     = 30
# Collector(s)
snowplow_collector_ami_id                       = "ami-059eeca93cf09eebd"
snowplow_collector_instance_class               = "t2.small"
snowplow_collector_root_block_size_gigs         = 50
snowplow_collector_node_count                   = 1
snowplow_collector_ingress_port                 = 8080
# Enricher
snowplow_enricher_ami_id                        = "ami-059eeca93cf09eebd"
snowplow_enricher_instance_class                = "t2.small"
snowplow_enricher_root_block_size_gigs          = 50
snowplow_enricher_node_count                    = 1 # LEAVE THIS AT ONE! Bump the instance class instead
# ---------------------------------------------------------
# Snowplow Operational
# ---------------------------------------------------------
# General
snowplow_service_user                           = "ubuntu"
snowplow_service_group                          = "ubuntu"
snowplow_home                                   = "/opt/snowplow"
# Collector
snowplow_collector_version                      = "0.14.0"
snowplow_collector_buffer_byte_limit            = 1000000
snowplow_collector_buffer_record_limit          = 1000
snowplow_collector_buffer_time_limit            = 300
snowplow_collector_good_stream                  = "collector-good"
snowplow_collector_good_shard_count             = 1
snowplow_collector_good_retention_hours         = 24
snowplow_collector_bad_stream                   = "collector-bad"
snowplow_collector_bad_shard_count              = 1
snowplow_collector_bad_retention_hours          = 24
# Enricher
snowplow_enricher_version                       = "0.19.1"
snowplow_enricher_buffer_byte_limit             = 1000000
snowplow_enricher_buffer_record_limit           = 1000
snowplow_enricher_buffer_time_limit             = 300
snowplow_enricher_good_stream                   = "enricher-good"
snowplow_enricher_good_shard_count              = 1
snowplow_enricher_good_retention_hours          = 24
snowplow_enricher_bad_stream                    = "enricher-bad"
snowplow_enricher_bad_shard_count               = 1
snowplow_enricher_bad_retention_hours           = 24
snowplow_enricher_pii_stream                    = "enricher-pii"
snowplow_enricher_pii_shard_count               = 1
snowplow_enricher_pii_retention_hours           = 24
snowplow_enricher_checkpoint_table              = "enricher-checkpoint"
snowplow_enricher_checkpoint_write_capacity     = 5
snowplow_enricher_checkpoint_read_capacity      = 5
# S3 Loader
snowplow_s3_loader_bucket                       = "collector-logs"
snowplow_s3_loader_version                      = "0.7.0"
snowplow_s3_loader_bad_stream                   = "s3-loader-bad"
snowplow_s3_loader_checkpoint_table             = "s3-loader-checkpoint"
snowplow_s3_loader_buffer_byte_limit            = 2000000
snowplow_s3_loader_buffer_record_limit          = 1000
snowplow_s3_loader_buffer_time_limit            = 600
