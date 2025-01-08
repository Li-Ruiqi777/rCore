#!/bin/bash

echo "start a new container : rCore"

docker run -it -d \
    --name rCore \
    -v /home/jiahan/Desktop/rCore:/workspace \
    --net host \
    -w / \
    rcore-tutorial-v3:latest
