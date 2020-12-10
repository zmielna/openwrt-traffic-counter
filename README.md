# Intro

Simple code to gather stats for IPs on internal network from OpenWRT based router

Based on the following post  https://forum.archive.openwrt.org/viewtopic.php?id=13748

with minor tweaks to meet my needs. Instead of pushing gathered data to SQL database as per original post I send it in JSON format to web served directory. It is then consumed by Telegraf service which is pulling data into Influxdb.

All credit for the idea goes to the original poster nickname nexus.

# Installation

* Copy processtraffic.sh from repo to /bin/processtraffic.sh
* Copy rules from firewall.user in repo to /etc/firewall.user
* Add cron job to /etc/crontabs/root

```
*/5 * * * * /bin/processtraffic.sh | grep -v '\"in\"\: \,' > /www/trafficCounters.json
```

* Restart cron

```
/etc/init.d/cron restart
```

# Get the data

Your stats should be now refreshed every 5minutes and available under:

http://192.168.0.254/trafficCounters.json

Assuming 192.168.0.254 is your router address.

# Consuming data with Telegraph and Graphana


I'm using Docker based TICK stack with Graphana



Here is my stack definition

```
version: '3.7'
services:
  telegraf:
    image: telegraf
    configs:
    - source: telegraf-conf
      target: /etc/telegraf/telegraf.conf
    ports:
    - 8186:8186
    volumes:
    - /usr/share/snmp/mibs:/usr/share/snmp/mibs
    - /var/lib/snmp/mibs/ietf:/var/lib/snmp/mibs/ietf
  influxdb:
    image: influxdb
    ports:
    - 8086:8086
    volumes:
    - /tank/appdata/influxdb:/var/lib/influxdb
  chronograf:
    image: chronograf
    ports:
    - 8888:8888
    command: ["chronograf", "--influxdb-url=http://influxdb:8086"]
  kapacitor:
    image: kapacitor
    environment:
    - KAPACITOR_INFLUXDB_0_URLS_0=http://influxdb:8086
    ports:
    - 9092:9092

configs:
  telegraf-conf:
    name: telegraf.conf-20201107-03
    file: ./telegraf.conf
```


and here goes telegraf configuration, note inputs.http section


```
# egrep -v '#|^$' telegraf.conf
[agent]
  interval = "5s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "5s"
  flush_jitter = "0s"
  precision = ""
  debug = false
  quiet = false
  logfile = ""
  hostname = "$HOSTNAME"
  omit_hostname = false
[[outputs.influxdb]]
  urls = ["http://influxdb:8086"]
  database = "test"
  username = ""
  password = ""
  retention_policy = ""
  write_consistency = "any"
  timeout = "5s"
[[inputs.http_listener]]
  service_address = ":8186"
[cpu]
  percpu = true
  totalcpu = true
[[inputs.mem]]
[[inputs.swap]]
[[inputs.system]]
[[inputs.http]]
  name_override = "openwrt"
  urls = [
    "http://192.168.0.254/trafficCounters.json"
  ]
  data_format = "json"
```


