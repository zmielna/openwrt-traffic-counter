#!/bin/sh

# get the data, and zero the counters
# get only info for IP where there is some traffic recorded, discard else
iptables -nvx -t mangle -L FORWARD | grep "all" |grep -v "       0        0" > /www/datadump.txt


cat /www/datadump.txt | while read line;
do
        # work out the direction
        seventhfield=$(echo "${line}" | awk '{print $7}')
        if [ $seventhfield != "0.0.0.0/0" ]; then
                #the direction is outbound from the ip in the seventh field
                direction='out'
                ip=$seventhfield
        fi

        eighthfield=$(echo "${line}" | awk '{print $8}')
        if [ $eighthfield != "0.0.0.0/0" ]; then
                #the direction is inbound to the ip in the eighth field
                direction='in'
                ip=$eighthfield
        fi

        #work out the bytes
        bytes=$(echo "${line}" | awk '{print $2}')

#        statement="insert into dump (bytes, direction, ip) values ($bytes,'$direction','$ip')"
        statement="$bytes,'$direction','$ip'"
        echo $statement 
        #psql -h 192.168.0.3 -U postgres -c "$statement" traffic
done
