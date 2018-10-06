#cloud-config
package_update: true
package_upgrade: true


packages:
    - awscli
    - unzip
    - prometheus-node-exporter


write_files:
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
                byteLimit = 300000
                recordLimit = 5
                timeLimit = 5000
              }
              appName = "${snowplow_enricher_checkpoint_table}"
            }
            # monitoring {
            #   snowplow {
            #     collectorUri = "{{collectorUri}}"
            #     collectorPort = 80
            #     appId = {{enrichAppName}}
            #     method = GET
            #   }
            # }
          }

      path: "${snowplow_home}/config.hocon"


runcmd:
    - [sh, -c, "sudo apt-get install default-jre -y"]
    - [sh, -c, "sudo mkdir ${snowplow_home}"]
    - [sh, -c, "wget https://bintray.com/snowplow/snowplow-generic/download_file?file_path=snowplow_stream_enrich_kinesis_${snowplow_enricher_version}.zip -O snowplow.zip"]
    - [sh, -c, "unzip snowplow.zip"]
    - [sh, -c, "mv snowplow-stream-enrich-kinesis-${snowplow_enricher_version}.jar ${snowplow_home}/"]
    - [ systemctl, daemon-reload ]
    - [ systemctl, enable, prometheus-node-exporter ]
    - [ systemctl, start, prometheus-node-exporter ]


power_state:
    delay: "+0"
    mode: reboot
    message: rebooting
    timeout: 15    
