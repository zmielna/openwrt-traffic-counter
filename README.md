# Intro

Simple code to gather stats for IPs on internal network from OpenWRT based router

Based on the following post  https://forum.archive.openwrt.org/viewtopic.php?id=13748

with minor tweaks to meet my needs. Instead of pushing gathered data to SQL database as per original post I send it to web served directory.

All credit for the idea goes to the original poster nickname nexus.

# Installation

* Copy processtraffic.sh from repo to /bin/processtraffic.sh
* Copy rules from firewall.user in repo to /etc/firewall.user
* Add cron job

```
echo "*/5 * * * * /bin/processtraffic.sh > /www/datadump2.txt" >>  /etc/crontabs/root

```

* Restart cron

```
/etc/init.d/cron restart
```

# Get the data

Your stats should be now refreshed every 5minutes and available under:

http://192.168.0.254/datadump2.txt

Assuming 192.168.0.254 is your router address.
