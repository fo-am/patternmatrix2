#!/bin/bash

echo "hello"

cd ../tabletloom
python driver4x4.py &
jellyfish tabletloom.scm &
