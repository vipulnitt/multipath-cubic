#!/bin/bash

# absolute path to project directory
PROJECT_PATH="`dirname \"$0\"`"
PROJECT_PATH="`( cd \"$PROJECT_PATH\" && pwd )`"
MODULE_PATH=$PROJECT_PATH/modules

sudo insmod $MODULE_PATH/tcptuner/tcp_tuner.ko
sudo insmod $MODULE_PATH/mpcubic/mpcubic.ko

sudo sysctl -w net.ipv4.tcp_congestion_control=tuner
sudo sysctl -w net.ipv4.tcp_congestion_control=mpcubic

sudo sysctl -w net.ipv4.ip_forward=1
