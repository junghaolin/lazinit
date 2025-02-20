#!/bin/sh
./looptail_kill.sh &
while true; do ./tail.sh;done
