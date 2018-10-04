#!/bin/bash

echo "robot"

killall -9 jellyfish
kill -9 $(ps ax | grep driver.py | fgrep -v grep | awk '{ print $1 }') 
kill -9 $(ps ax | grep driver-fabric.py | fgrep -v grep | awk '{ print $1 }') 

cd ../robotics
python driver.py &

