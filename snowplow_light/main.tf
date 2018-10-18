resource "aws_s3_bucket" "pixel_bucket" {
  bucket = "${var.env}-${var.department}-${var.snowplow_system_tag}-lt-src"
  acl    = "public-read"

  tags {
    Name       = "${var.env}-${var.department}-${var.snowplow_system_tag}-lt-src"
    Env        = "${var.env}"
    Department = "${var.department}"
    System     = "${var.snowplow_system_tag}"
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket       = "${aws_s3_bucket.pixel_bucket.bucket}"
  key          = "i"
  source       = "${path.module}/files/i"
  content_type = "image/gif"
  etag         = "${md5(file("${path.module}/files/i"))}"
  acl          = "public-read"
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket = "${var.env}-${var.department}-${var.snowplow_system_tag}-lt-logs"
  acl    = "private"

  tags {
    Name       = "${var.env}-${var.department}-${var.snowplow_system_tag}-lt-logs"
    Env        = "${var.env}"
    Department = "${var.department}"
    System     = "${var.snowplow_system_tag}"
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.pixel_bucket.bucket_regional_domain_name}"
    origin_id   = "$s3-${var.env}-${var.department}-${var.snowplow_system_tag}-lt-src"
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Cloudfront distribution for snowplow tracking pixel"

  logging_config {
    include_cookies = true
    bucket          = "${aws_s3_bucket.logs_bucket.bucket_regional_domain_name}"
    prefix          = "raw"
  }

  aliases = ["i.${var.primary_domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "$s3-${var.env}-${var.department}-${var.snowplow_system_tag}-lt-src"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["AF", "AX", "AL", "DZ", "AS", "AD", "AO", "AI", "AQ", "AG", "AR", "AM", "AW", "AU", "AT", "AZ", "BS", "BH", "BD", "BB", "BY", "BE", "BZ", "BJ", "BM", "BT", "BO", "BQ", "BA", "BW", "BV", "BR", "IO", "BN", "BG", "BF", "BI", "CV", "KH", "CM", "CA", "KY", "CF", "TD", "CL", "CN", "CX", "CC", "CO", "KM", "CG", "CD", "CK", "CR", "CI", "HR", "CU", "CW", "CY", "CZ", "DK", "DJ", "DM", "DO", "EC", "EG", "SV", "GQ", "ER", "EE", "SZ", "ET", "FK", "FO", "FJ", "FI", "FR", "GF", "PF", "TF", "GA", "GM", "GE", "DE", "GH", "GI", "GR", "GL", "GD", "GP", "GU", "GT", "GG", "GN", "GW", "GY", "HT", "HM", "VA", "HN", "HK", "HU", "IS", "IN", "ID", "IR", "IQ", "IE", "IM", "IL", "IT", "JM", "JP", "JE", "JO", "KZ", "KE", "KI", "KP", "KR", "KW", "KG", "LA", "LV", "LB", "LS", "LR", "LY", "LI", "LT", "LU", "MO", "MK", "MG", "MW", "MY", "MV", "ML", "MT", "MH", "MQ", "MR", "MU", "YT", "MX", "FM", "MD", "MC", "MN", "ME", "MS", "MA", "MZ", "MM", "NA", "NR", "NP", "NL", "NC", "NZ", "NI", "NE", "NG", "NU", "NF", "MP", "NO", "OM", "PK", "PW", "PS", "PA", "PG", "PY", "PE", "PH", "PN", "PL", "PT", "PR", "QA", "RE", "RO", "RU", "RW", "BL", "SH", "KN", "LC", "MF", "PM", "VC", "WS", "SM", "ST", "SA", "SN", "RS", "SC", "SL", "SG", "SX", "SK", "SI", "SB", "SO", "ZA", "GS", "SS", "ES", "LK", "SD", "SR", "SJ", "SE", "CH", "SY", "TW", "TJ", "TZ", "TH", "TL", "TG", "TK", "TO", "TT", "TN", "TR", "TM", "TC", "TV", "UG", "UA", "AE", "GB", "US", "UM", "UY", "UZ", "VU", "VE", "VN", "VG", "VI", "WF", "EH", "YE", "ZM", "ZW"]
    }
  }

  tags {
    Name       = "${var.env}-${var.department}-${var.snowplow_system_tag}-cf-dist"
    Env        = "${var.env}"
    Department = "${var.department}"
    System     = "${var.snowplow_system_tag}"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
