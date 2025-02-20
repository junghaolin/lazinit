#!/bin/ash
i=0
while true; do
  wnc_mqtts_send_telemetry "{\"msg\":$i}"
  echo "[$(date)]{\"msg\":$i}" 
  # usleep 100000  # 100000微秒 = 0.1秒
  i=$((i+1))
done

