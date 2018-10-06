#cloud-config
package_update: true
package_upgrade: true


packages:
    - awscli
    - unzip
    - prometheus-node-exporter


write_files:
    - content: |
            collector {
              interface = "0.0.0.0"
              port = ${snowplow_collector_ingress_port}
              p3p {
                policyRef = "/w3c/p3p.xml"
                CP = "NOI DSP COR NID PSA OUR IND COM NAV STA"
              }
              crossDomain {
                enabled = false
                domains = [ "*" ]
                secure = true
              }

              cookie {
                enabled = true
                expiration = "365 days"
                name = "sp-nuid"
                #domain = "{{cookieDomain}}"
              }

              doNotTrackCookie {
                enabled = false
                name = "dnt"
                value = "1"
              }

              cookieBounce {
                enabled = false
                name = "n3pc"
                fallbackNetworkUserId = "00000000-0000-4000-A000-000000000000"
                forwardedProtocolHeader = "X-Forwarded-Proto"
              }

              redirectMacro {
                enabled = false
                placeholder = "[TOKEN]"
              }

              rootResponse {
                enabled = false
                statusCode = 302
                headers = {
                    Location = "https://127.0.0.1/",
                    X-Custom = "something"
                }
                body = "302, redirecting"
              }

              streams {
                good = "${var.env}-${var.snowplow_system_tag}-${var.snowplow_collector_good_stream}"
                bad = "${var.env}-${var.snowplow_system_tag}-${var.snowplow_collector_bad_stream}"
                useIpAddressAsPartitionKey = false
                sink {
                  enabled = kinesis
                  region = "${aws_region}"
                  threadPoolSize = 10
                  aws {
                    accessKey = "${operator_access_key_id}"
                    secretKey = "${operator_secret_access_key}"
                  }
                  backoffPolicy {
                    minBackoff = 1000
                    maxBackoff = 10000
                  }
                }

                buffer {
                  byteLimit = 300000
                  recordLimit = 5
                  timeLimit = 5000
                }
              }
            }

            akka {
              loglevel = DEBUG # 'OFF' for no logging, 'DEBUG' for all logging.
              loggers = ["akka.event.slf4j.Slf4jLogger"]
              http.server {
                remote-address-header = on
                raw-request-uri-header = on
                parsing {
                  max-uri-length = 32768
                  uri-parsing-mode = relaxed
                }
              }
            }
      path: "${snowplow_home}/config.hocon"

    - content: |
            [Unit]
            Description=Snowplow collector daemon
            After=network.target

            [Service]
            PermissionsStartOnly=true
            User=${snowplow_service_user}
            Group=${snowplow_service_group}
            ExecStartPre=/bin/chown -R ${snowplow_service_user}:${snowplow_service_group} ${snowplow_home}
            ExecStartPre=/bin/mkdir /run/snowplow-collector
            ExecStartPre=/bin/chown -R ${snowplow_service_user}:${snowplow_service_group} /run/snowplow-collector
            ExecStart=java -jar ${snowplow_home}/snowplow-stream-collector-kinesis-${snowplow_collector_version}.jar --config ${snowplow_home}/config.hocon
            ExecStop=/bin/kill -s TERM $MAINPID
            ExecStopPost=/bin/rm -rf /run/snowplow-collector
            Restart=always
            RestartSec=5s
            MemoryMax=2G

            [Install]
            WantedBy=multi-user.target
      path: "/etc/systemd/system/snowplow-collector.service"


runcmd:
    - [sh, -c, "sudo apt-get install default-jre -y"]
    - [sh, -c, "sudo mkdir ${snowplow_home}"]
    - [sh, -c, "wget https://bintray.com/snowplow/snowplow-generic/download_file?file_path=snowplow_scala_stream_collector_kinesis_${snowplow_collector_version}.zip -O snowplow.zip"]
    - [sh, -c, "unzip snowplow.zip"]
    - [sh, -c, "mv snowplow-stream-collector-kinesis-${snowplow_collector_version}.jar ${snowplow_home}/"]


power_state:
    delay: "+0"
    mode: reboot
    message: rebooting
    timeout: 15    
