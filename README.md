# Intro

Simple code to gather stats for IPs on internal network from OpenWRT based router

Based on the following post  https://forum.archive.openwrt.org/viewtopic.php?id=13748

with minor tweaks to meet my needs. Instead of pushing gathered data to SQL database as per original post I send it to...

All credit for the idea goes to the original poster nickname nexus.

# Installation

* Copy processtraffic.sh from repo to /bin/processtraffic.sh
* Copy rules from firewall.user in repo to /etc/firewall.user
* Add cron job

```
echo "*/5 * * * * /bin/processtraffic.sh > /tmp/ptlog" >>  /etc/crontabs/root

```
