# ---------------------------------------------------------
# Generic
# ---------------------------------------------------------
variable "aws_access_key_id" {
  type        = "string"
  description = "admin-level access key id"
}

variable "aws_secret_access_key" {
  type        = "string"
  description = "admin-level secret access key"
}

variable "env" {
  type        = "string"
  description = "the env to deploy into"
}

variable "department" {
  type        = "string"
  description = "the department to be tagged"
}

variable "aws_region" {
  type        = "string"
  description = "the aws region"
}

variable "az_count" {
  type        = "string"
  description = "the number of azs to use"
}

# ---------------------------------------------------------
# VPC
# ---------------------------------------------------------

variable "vpc_cidr" {
  type        = "string"
  description = "the cidr to use for the instantiated vpc"
}

variable "vpc_basename" {
  type        = "string"
  description = "the base name to use for the vpc"
}

# ---------------------------------------------------------
# Snowplow Infrastructure
# ---------------------------------------------------------
variable "snowplow_service_user" {
  type        = "string"
  description = "the service user to use"
}

variable "snowplow_service_group" {
  type        = "string"
  description = "the service group to use"
}

variable "snowplow_home" {
  type        = "string"
  description = "the snowplow home directory"
}

variable "snowplow_system_tag" {
  type        = "string"
  description = "the system tag for all snowplow resources"
}

variable "snowplow_ec2_keypair" {
  type        = "string"
  description = "the name of the ec2 keypair to instantiate images with"
}

variable "snowplow_ec2_keypair_path" {
  type        = "string"
  description = "the local path for the ec2 keypair used for provisioning ec2 resources"
}

variable "snowplow_lb_port" {
  type        = "string"
  description = ""
}

variable "snowplow_lb_protocol" {
  type        = "string"
  description = ""
}

variable "snowplow_lb_target_group_protocol" {
  type        = "string"
  description = ""
}

variable "snowplow_lb_health_path" {
  type        = "string"
  description = ""
}

variable "snowplow_lb_healthy_threshold" {
  type        = "string"
  description = ""
}

variable "snowplow_lb_unhealthy_threshold" {
  type        = "string"
  description = ""
}

variable "snowplow_lb_health_timeout" {
  type        = "string"
  description = ""
}

variable "snowplow_lb_health_interval" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_ami_id" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_instance_class" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_root_block_size_gigs" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_node_count" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_ingress_port" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_ami_id" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_instance_class" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_root_block_size_gigs" {
  type        = "string"
  description = ""
}

# ---------------------------------------------------------
# Snowplow Operational
# ---------------------------------------------------------

variable "snowplow_enricher_node_count" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_version" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_buffer_byte_limit" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_buffer_record_limit" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_buffer_time_limit" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_good_stream" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_good_shard_count" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_good_retention_hours" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_bad_stream" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_bad_shard_count" {
  type        = "string"
  description = ""
}

variable "snowplow_collector_bad_retention_hours" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_version" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_buffer_byte_limit" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_buffer_record_limit" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_buffer_time_limit" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_good_stream" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_good_shard_count" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_good_retention_hours" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_bad_stream" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_bad_shard_count" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_bad_retention_hours" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_pii_stream" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_pii_shard_count" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_pii_retention_hours" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_checkpoint_table" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_checkpoint_write_capacity" {
  type        = "string"
  description = ""
}

variable "snowplow_enricher_checkpoint_read_capacity" {
  type        = "string"
  description = ""
}

variable "snowplow_sink_version" {
  type        = "string"
  description = ""
}

variable "snowplow_sink_buffer_byte_limit" {
  type        = "string"
  description = ""
}

variable "snowplow_sink_buffer_record_limit" {
  type        = "string"
  description = ""
}

variable "snowplow_sink_buffer_time_limit" {
  type        = "string"
  description = ""
}

variable "snowplow_sink_good_s3_bucket" {
  type        = "string"
  description = ""
}

variable "snowplow_sink_bad_stream" {
  type        = "string"
  description = ""
}

variable "snowplow_sink_bad_shard_count" {
  type        = "string"
  description = ""
}

variable "snowplow_sink_checkpoint_table" {
  type        = "string"
  description = ""
}

variable "snowplow_sink_checkpoint_write_capacity" {
  type        = "string"
  description = ""
}

variable "snowplow_sink_checkpoint_read_capacity" {
  type        = "string"
  description = ""
}
