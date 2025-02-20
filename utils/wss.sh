#!/bin/ash
while true; do
 PID=$(ps|grep wnc_mqtts_agent|grep -v grep|awk '{print $1}')
 echo [$(date)] $(cat /proc/$PID/status|grep VmRSS)
 sleep 1
done
