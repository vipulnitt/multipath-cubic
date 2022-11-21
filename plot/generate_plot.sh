#!/bin/bash

# absolute path to project directory
SCRIPT_DIR="`dirname \"$0\"`"
SCRIPT_DIR="`( cd \"$PROJECT_PATH\" && pwd )`"

gnuplot $SCRIPT_DIR/snd_cwnd.plot

epstopdf $SCRIPT_DIR/snd_cwnd_plot.eps
