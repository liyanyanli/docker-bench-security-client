#!/usr/bin/env bash

#$1 harbor ip  $2 24  $3 1  $4 path

cd $4

sed -i "s/.*\"HarborIp\":.*/\"HarborIp\": \"$1\",/" bench-security-conf.json

sed -i "s/.*\"Freq\":.*/\"Freq\": $2,/" bench-security-conf.json

sed -i "s/.*\"FreqRuntime\":.*/\"FreqRuntime\": $3/" bench-security-conf.json

nohup ./bench-security-runtime >/dev/null 2>&1 </dev/null &

nohup ./docker-bench-security >/dev/null 2>&1 </dev/null &


grep -wq "./usr/local/deploy-harbor/docker-bench-security-harmony/bench-security-runtime >/dev/null 2>&1 </dev/null &" /etc/rc.local &> /dev/null
if [ $? -ne 0 ]
then
sed -i "/multiuser/i\nohup ./usr/local/deploy-harbor/docker-bench-security-harmony/bench-security-runtime >/dev/null 2>&1 </dev/null &" /etc/rc.local
fi

grep -wq "nohup ./usr/local/deploy-harbor/docker-bench-security-harmony/docker-bench-security >/dev/null 2>&1 </dev/null &" /etc/rc.local &> /dev/null
if [ $? -ne 0 ]
then
sed -i "/multiuser/i\nohup ./usr/local/deploy-harbor/docker-bench-security-harmony/docker-bench-security >/dev/null 2>&1 </dev/null &" /etc/rc.local
fi




#nohup cd $4 && ./bench-security-runtime >/dev/null 2>&1 </dev/null &
#
#nohup cd $4 && ./docker-bench-security >/dev/null 2>&1 </dev/null &
#
#grep -wq "nohup cd $4 && ./bench-security-runtime >/dev/null 2>&1 </dev/null &" /etc/rc.local &> /dev/null
#if [ $? -ne 0 ]
#then
#sed -i "/multiuser/i\nohup cd $4 && ./bench-security-runtime >/dev/null 2>&1 </dev/null &" /etc/rc.local
#fi
#
#grep -wq "nohup cd $4 && ./docker-bench-security >/dev/null 2>&1 </dev/null &" /etc/rc.local &> /dev/null
#if [ $? -ne 0 ]
#then
#sed -i "/multiuser/i\nohup cd $4 && ./docker-bench-security >/dev/null 2>&1 </dev/null &" /etc/rc.local
#fi