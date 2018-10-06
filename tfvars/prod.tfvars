# ---------------------------------------------------------
# Generic
# ---------------------------------------------------------
env                                             = "prod"
department                                      = "bostata"
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
snowplow_system_tag                             = "snowplow"
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
snowplow_collector_node_count                   = 2
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
snowplow_collector_buffer_byte_limit            = ""
snowplow_collector_buffer_record_limit          = ""
snowplow_collector_buffer_time_limit            = ""
snowplow_collector_good_stream                  = "collector-good"
snowplow_collector_good_shard_count             = 1
snowplow_collector_good_retention_hours         = 24
snowplow_collector_bad_stream                   = "collector-bad"
snowplow_collector_bad_shard_count              = 1
snowplow_collector_bad_retention_hours          = 24
# Enricher
snowplow_enricher_version                       = "0.13.0"
snowplow_enricher_buffer_byte_limit             = ""
snowplow_enricher_buffer_record_limit           = ""
snowplow_enricher_buffer_time_limit             = 100
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
# Sink
snowplow_sink_version                           = "0.6.0"
snowplow_sink_buffer_byte_limit                 = ""
snowplow_sink_buffer_record_limit               = ""
snowplow_sink_buffer_time_limit                 = ""
snowplow_sink_good_s3_bucket                    = ""
snowplow_sink_bad_stream                        = "sink-bad"
snowplow_sink_bad_shard_count                   = 1
snowplow_sink_checkpoint_table                  = "sink-checkpoint"
snowplow_sink_checkpoint_write_capacity         = 5
snowplow_sink_checkpoint_read_capacity          = 5
