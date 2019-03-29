
module "snowplow_light" {
  source              = "./snowplow_light"
  env                 = "stage"
  department          = "data"
  primary_domain      = "bostata.com"
  aws_region          = "us-east-1"
  snowplow_system_tag = "sp"
}
