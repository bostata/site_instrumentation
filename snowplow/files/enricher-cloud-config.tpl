#cloud-config
package_update: true
package_upgrade: true


packages:
    - awscli
    - unzip
    - prometheus-node-exporter
    - python-pip


write_files:
    - content: |
              {
                "schema": "iglu:com.snowplowanalytics.snowplow.enrichments/http_header_extractor_config/jsonschema/1-0-0",
                "data": {
                  "name": "http_header_extractor_config",
                  "vendor": "com.snowplowanalytics.snowplow.enrichments",
                  "enabled": true,
                  "parameters": {
                    "headersPattern": [".*"]
                  }
                }
              }
      path: "${snowplow_home}/enrichments/http_header_extractor_config.json"

    - content: |
              {
                "schema": "iglu:com.snowplowanalytics.snowplow/cookie_extractor_config/jsonschema/1-0-0",
                "data": {
                  "name": "cookie_extractor_config",
                  "vendor": "com.snowplowanalytics.snowplow",
                  "enabled": true,
                  "parameters": {
                    "cookies": ["sp"]
                  }
                }
              }
      path: "${snowplow_home}/enrichments/cookie_extractor_config.json"

    - content: |
              {
                  "schema": "iglu:com.snowplowanalytics.snowplow/event_fingerprint_config/jsonschema/1-0-0",

                  "data": {

                      "name": "event_fingerprint_config",
                      "vendor": "com.snowplowanalytics.snowplow",
                      "enabled": true,
                      "parameters": {
                          "excludeParameters": ["eid", "stm"],
                          "hashAlgorithm": "MD5"
                      }
                  }
              }
      path: "${snowplow_home}/enrichments/event_fingerprint_enrichment.json"

    - content: |
              {
                  "schema": "iglu:com.snowplowanalytics.snowplow/user_agent_utils_config/jsonschema/1-0-0",
                  "data": {
                      "vendor": "com.snowplowanalytics.snowplow",
                      "name": "user_agent_utils_config",
                      "enabled": true,
                      "parameters": {}
                }
              }
      path: "${snowplow_home}/enrichments/user_agent_utils_config.json"

    - content: |
              {
                "schema": "iglu:com.snowplowanalytics.snowplow/ua_parser_config/jsonschema/1-0-0",
                "data": {
                  "vendor": "com.snowplowanalytics.snowplow",
                  "name": "ua_parser_config",
                  "enabled": true,
                  "parameters": {}
                }
              }
      path: "${snowplow_home}/enrichments/ua_parser_config.json"

    - content: |
              {
                "schema": "iglu:com.snowplowanalytics.snowplow/referer_parser/jsonschema/1-0-0",

                "data": {

                  "name": "referer_parser",
                  "vendor": "com.snowplowanalytics.snowplow",
                  "enabled": true,
                  "parameters": {
                    "internalDomains": [
                      "*.${primary_domain}",
                    ]
                  }
                }
              }
      path: "${snowplow_home}/enrichments/referrer_parser_config.json"

    - content: |
              {
                "schema": "iglu:com.snowplowanalytics.snowplow/campaign_attribution/jsonschema/1-0-1",

                "data": {

                  "name": "campaign_attribution",
                  "vendor": "com.snowplowanalytics.snowplow",
                  "enabled": true,
                  "parameters": {
                    "mapping": "static",
                    "fields": {
                      "mktMedium": ["utm_medium"],
                      "mktSource": ["utm_source"],
                      "mktTerm": ["utm_term"],
                      "mktContent": ["utm_content"],
                      "mktCampaign": ["utm_campaign"]
                    }
                  }
                }
              }
      path: "${snowplow_home}/enrichments/campaign_attribution_config.json"

    - content: |
              {
                "schema": "iglu:com.snowplowanalytics.snowplow/ip_lookups/jsonschema/2-0-0",

                "data": {

                  "name": "ip_lookups",
                  "vendor": "com.snowplowanalytics.snowplow",
                  "enabled": true,
                  "parameters": {
                    "geo": {
                      "database": "GeoLite2-City.mmdb",
                      "uri": "http://snowplow-hosted-assets.s3.amazonaws.com/third-party/maxmind"
                    }
                  }
                }
              }
      path: "${snowplow_home}/enrichments/ip_lookups_config.json"

    - content: |
          127.0.0.1 ${env}-${department}-${snowplow_system_tag}-enricher
          # The following lines are desirable for IPv6 capable hosts
          ::1 ip6-localhost ip6-loopback
          fe00::0 ip6-localnet
          ff00::0 ip6-mcastprefix
          ff02::1 ip6-allnodes
          ff02::2 ip6-allrouters
          ff02::3 ip6-allhosts

      path: "/etc/hosts"

    - content: |
          ${env}-${department}-${snowplow_system_tag}-enricher

      path: "/etc/hostname"

    - content: |
          enrich {
            streams {
              in {
                raw = "${env}-${department}-${snowplow_system_tag}-${snowplow_collector_good_stream}"
              }
              out {
                enriched = "${env}-${department}-${snowplow_system_tag}-${snowplow_enricher_good_stream}"
                bad = "${env}-${department}-${snowplow_system_tag}-${snowplow_enricher_bad_stream}"
                pii = "${env}-${department}-${snowplow_system_tag}-${snowplow_enricher_pii_stream}"
                partitionKey = event_id
              }

              sourceSink {
                enabled =  kinesis

                region = "${aws_region}"
                aws {
                  accessKey = "${operator_access_key_id}"
                  secretKey = "${operator_secret_access_key}"
                }
                maxRecords = 10000
                initialPosition = TRIM_HORIZON
                #initialTimestamp = "{{initialTimestamp}}"
                backoffPolicy {
                  minBackoff = 1000
                  maxBackoff = 10000
                }
                retries = 5
              }

              buffer {
                byteLimit = ${snowplow_enricher_buffer_byte_limit}
                recordLimit = ${snowplow_enricher_buffer_record_limit}
                timeLimit = ${snowplow_enricher_buffer_time_limit}
              }
              appName = "${env}-${department}-${snowplow_enricher_checkpoint_table}"
            }
            monitoring {
              snowplow {
                collectorUri = ${snowplow_collector_uri}
                collectorPort = ${snowplow_collector_ingress_port}
                appId = enricher-monitoring
                method = GET
              }
            }
          }

      path: "${snowplow_home}/enricher-config.hocon"

    - content: |
            {
              "schema": "iglu:com.snowplowanalytics.iglu/resolver-config/jsonschema/1-0-1",
              "data": {
                "cacheSize": 500,
                "repositories": [
                  {
                    "name": "Iglu Central",
                    "priority": 0,
                    "vendorPrefixes": [ "com.snowplowanalytics" ],
                    "connection": {
                      "http": {
                        "uri": "http://iglucentral.com"
                      }
                    }
                  },
                  {
                    "name": "Iglu Central - GCP Mirror",
                    "priority": 1,
                    "vendorPrefixes": [ "com.snowplowanalytics" ],
                    "connection": {
                      "http": {
                        "uri": "http://mirror01.iglucentral.com"
                      }
                    }
                  }
                ]
              }
            }
      path: "${snowplow_home}/resolver.js"

    - content: |
          [Unit]
          Description=Snowplow enricher daemon
          After=network.target

          [Service]
          PermissionsStartOnly=true
          User=${snowplow_service_user}
          Group=${snowplow_service_group}
          ExecStartPre=/bin/chown -R ${snowplow_service_user}:${snowplow_service_group} ${snowplow_home}
          ExecStartPre=/bin/mkdir /run/snowplow-enricher
          ExecStartPre=/bin/chown -R ${snowplow_service_user}:${snowplow_service_group} /run/snowplow-enricher
          ExecStart=/usr/bin/java -jar ${snowplow_home}/snowplow-stream-enrich-kinesis-${snowplow_enricher_version}.jar --config ${snowplow_home}/enricher-config.hocon --resolver file:${snowplow_home}/resolver.js --enrichments file:${snowplow_home}/
          ExecStop=/bin/kill -s TERM $MAINPID
          ExecStopPost=/bin/rm -rf /run/snowplow-enricher
          Restart=always
          RestartSec=5s

          [Install]
          WantedBy=multi-user.target
      path: "/etc/systemd/system/snowplow-enricher.service"

    - content: |
          source = "kinesis"
          sink = "kinesis"

          aws {
            accessKey = "${operator_access_key_id}"
            secretKey = "${operator_secret_access_key}"
          }

          nsq {
            channelName = "{{nsqSourceChannelName}}"
            host = "{{nsqHost}}"
            port = 1
            lookupPort = 1
          }

          kinesis {
            initialPosition = "TRIM_HORIZON"
            maxRecords = 10000
            region = "${aws_region}"
            appName = "${env}-${department}-${snowplow_s3_loader_checkpoint_table}"
          }

          streams {
            inStreamName = "${env}-${department}-${snowplow_system_tag}-${snowplow_enricher_good_stream}"
            outStreamName = "${env}-${department}-${snowplow_system_tag}-${snowplow_s3_loader_bad_stream}"
            buffer {
              byteLimit = ${snowplow_s3_loader_buffer_byte_limit}
              recordLimit = ${snowplow_s3_loader_buffer_record_limit}
              timeLimit = ${snowplow_s3_loader_buffer_time_limit}
            }
          }

          s3 {
            region = "${aws_region}"
            bucket = "${env}-${department}-${snowplow_system_tag}-${snowplow_s3_loader_bucket}"
            directoryPattern = "enriched/good/{YYYY}/{MM}/{dd}"
            format = "gzip"
            maxTimeout = 2000
          }

          monitoring {
            snowplow{
              collectorUri = "${snowplow_collector_uri}"
              collectorPort = ${snowplow_collector_ingress_port}
              appId = "s3-loader-monitoring"
              method = "GET"
            }
          }
      path: "${snowplow_home}/s3-loader-config.hocon"

    - content: |
          [Unit]
          Description=Snowplow s3 loader daemon
          After=network.target

          [Service]
          PermissionsStartOnly=true
          User=${snowplow_service_user}
          Group=${snowplow_service_group}
          ExecStartPre=/bin/chown -R ${snowplow_service_user}:${snowplow_service_group} ${snowplow_home}
          ExecStartPre=/bin/mkdir /run/snowplow-s3-loader
          ExecStartPre=/bin/chown -R ${snowplow_service_user}:${snowplow_service_group} /run/snowplow-s3-loader
          ExecStart=/usr/bin/java -jar ${snowplow_home}/snowplow-s3-loader-${snowplow_s3_loader_version}-rc1.jar --config ${snowplow_home}/s3-loader-config.hocon
          ExecStop=/bin/kill -s TERM $MAINPID
          ExecStopPost=/bin/rm -rf /run/snowplow-s3-loader
          Restart=always
          RestartSec=5s

          [Install]
          WantedBy=multi-user.target
      path: "/etc/systemd/system/snowplow-s3-loader.service"

    - content: |
          from snowplow_tracker import Subject, Tracker, Emitter
          import time


          SNOWPLOW_URL = '${snowplow_collector_uri}'


          def test_collectors():
              e = Emitter(SNOWPLOW_URL)
              t = Tracker(e)
              t.subject.set_platform("test-plat").set_user_id("test-user").set_lang("en")
              while True:
                  t.track_page_view("www.test-host.com", "test-page", "www.test-referrer.com")
                  time.sleep(0.2)


          if __name__ == '__main__':
              test_collectors()
      path: "${snowplow_home}/test_collectors.py"


runcmd:
    - [ sh, -c, "sudo pip install --upgrade pip && sudo pip install ipython && sudo pip install snowplow-tracker"]
    - [ sh, -c, "sudo apt-get install default-jre -y" ]
    - [ sh, -c, "sudo mkdir ${snowplow_home}" ]
    - [ sh, -c, "wget https://bintray.com/snowplow/snowplow-generic/download_file?file_path=snowplow_stream_enrich_kinesis_${snowplow_enricher_version}.zip -O sp-enricher.zip" ]
    - [ sh, -c, "unzip sp-enricher.zip" ]
    - [ sh, -c, "mv snowplow-stream-enrich-kinesis-${snowplow_enricher_version}.jar ${snowplow_home}/" ]
    - [ sh, -c, "wget https://bintray.com/snowplow/snowplow-generic/download_file?file_path=snowplow_s3_loader_${snowplow_s3_loader_version}_rc1.zip -O sp-s3-loader.zip" ]
    - [ sh, -c, "unzip sp-s3-loader.zip" ]
    - [sh, -c, "mv snowplow-s3-loader-${snowplow_s3_loader_version}-rc1.jar  ${snowplow_home}/"]
    - [ systemctl, daemon-reload ]
    - [ systemctl, enable, prometheus-node-exporter ]
    - [ systemctl, enable, snowplow-enricher.service ]
    - [ systemctl, enable, snowplow-s3-loader.service ]
    - [ systemctl, start, prometheus-node-exporter ]


power_state:
    delay: "+0"
    mode: reboot
    message: rebooting
    timeout: 15    
