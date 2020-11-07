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
*/15 * * * * /bin/processtraffic.sh | grep -v '\"in\"\: \,' > /www/trafficCounters.json
```

* Restart cron

```
/etc/init.d/cron restart
```

# Get the data

Your stats should be now refreshed every 5minutes and available under:

http://192.168.0.254/trafficCounters.json

Assuming 192.168.0.254 is your router address.
