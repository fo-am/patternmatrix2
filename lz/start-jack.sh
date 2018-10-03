#!/bin/bash
eval `dbus-launch --auto-syntax`
sleep 2
export DBUS_SESSION_BUS_PID DBUS_SESSION_BUS_ADDRESS
sleep 2
export DISPLAY=:0.0
sleep 2
jackd -p32 -dalsa -dhw:1,0 -p1024 -n3 -s -r44100 &
