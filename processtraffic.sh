#!/bin/sh

# get the data
# get only info for IP where there is some traffic recorded, discard else
iptables -nvx -t mangle -L FORWARD | grep "all" |grep -v "       0        0" > /tmp/datadump.txt
DATAFILE=/tmp/datadump.txt
echo {
for host in `awk '{print $7}' $DATAFILE |sort |grep -v "0.0.0.0/0"|uniq` 
    do
    grep $host $DATAFILE | while read line;
        do
        seventhfield=$(echo "${line}" | awk '{print $7}')
        eighthfield=$(echo "${line}" | awk '{print $8}')
        # work out the direction
        if [ $seventhfield != "0.0.0.0/0" ]; then
                #the direction is outbound from the ip in the seventh field
                # directionOut='out'
                #work out the bytes
                bytesOut=$(echo "${line}" | awk '{print $2}')
        fi    
        if [ $eighthfield != "0.0.0.0/0" ]; then
                #the direction is inbound to the ip in the eighth field
                # directionIn='in'
                # ip=$eighthfield
                #work out the bytes
                bytesIn=$(echo "${line}" | awk '{print $2}')
        fi 
        statement="\"$host\": { \"in\": $bytesIn, \"out\": $bytesOut }," 
        echo $statement
    done

done
# Adding dummy line without trailing comma sign. Dirty hack, looking to improve!
echo '"6.6.6.6": { "in": 0, "out": 0 }'
echo }
