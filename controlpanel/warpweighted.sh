#!/bin/bash

echo "warpweighted"

killall -9 jellyfish
kill -9 $(ps ax | grep driver.py | fgrep -v grep | awk '{ print $1 }') 
kill -9 $(ps ax | grep driver-fabric.py | fgrep -v grep | awk '{ print $1 }') 

cd ../warpweighted
python driver-fabric.py &
jellyfish wwloomsim4.scm &
