# TCPTuner
TCPTuner is TCP congestion control kernel module and GUI packaged together. By loading this kernel module and running the GUI, users can adjust several parameters of the CUBIC congestion control algorithm.

Two variations of CUBIC congestion control algorithm are implemented here:
* Conventional CUBIC ([reference paper](https://arxiv.org/ftp/arxiv/papers/1605/1605.01987.pdf))
* Multipath CUBIC ([reference paper](https://www.researchgate.net/publication/341995073_mpCUBIC_A_CUBIC-like_Congestion_Control_Algorithm_for_Multipath_TCP))

[Project report](report.pdf)

## How to Build and Load the Kernel Modules

**This version of the project was developed and tested on an Ubuntu 20.04 machine running version 5.11 of the Linux kernel**

To build the tcptuner kernel module:
``` bash
cd module/tcptuner
make
sudo rmmod tcp_tuner.ko
sudo insmod tcp_tuner.ko
sudo sysctl -w net.ipv4.tcp_congestion_control=tuner # make 'tuner' the default choice for the system
```

Follow similar steps to build other kernel modules in `modules` directory.

## The Graphical User Interface
### Dependencies

First install the following packages:
``` bash
sudo apt-get install qt5-qmake qt5-default
```

### To Build and Run

To build and run the TCPTuner GUI:
``` bash
cd gui/TCPTuner
qmake
make
sudo ./TCPTuner
```

Follow similar steps to build and run the mpCUBIC GUI.

## GUI Parameters
TCPTuner exposes the parameters of TCP CUBIC to the user via the TCPTuner GUI. The parameters present in TCP CUBIC, along with their descriptions and default values are in the table below.

Parameter        | Description                                                                 | Default
:--------------: | :-------------------------------------------------------------------------- | :-----:
alpha            | Scales W_max, which adjusts the rate at which cwnd grows after a loss event | 512
beta             | beta for multiplicative decrease                                            | 717
fast_convergence | turn on/off fast convergence                                                | 1
tcp_friendliness | turn on/off tcp friendliness                                                | 1

### Additonal Parameters from ip-route
The TCPTuner GUI also provides access to the following `ip route` parameters. The GUI will apply these `ip route` parameters to all of the routes in the routing table.

Parameter | Description                                                                                                                 | Default
:-------: | :-------------------------------------------------------------------------------------------------------------------------- | :------:
rto_min   | the minimum TCP retransmission timeout to use when communicating with this destination.                                     | None
initcwnd  | the initial congestion window size for connections to this destination. Actual window size is this value multiplied by MSS. | 0

## MahiMahi Simulation Environment
This repository also contains a [MahiMahi](http://mahimahi.mit.edu/) simulation environment so that users can see the impact of TCP congestion control parameters.

### Dependencies
First, you must install the mahimahi package:
``` bash
sudo apt-get install mahimahi
```

Before you can run MahiMahi, you must:
``` bash
sudo sysctl -w net.ipv4.ip_forward=1
```

### Single TCP Flow with tail-drop Buffer
The first simulation shows throughput and delay of a single TCP flow on a 12Mbps uplink.

``` bash
cd mahimahi
./start_all 0 # default cubic client
./start_all 1 # tuner cubic client
./start_all 2 # mpcubic client
```

### Multiple TCP Flows Sharing a Bottleneck Link
The second simulation shows throughput graphs of each flow sharing a bottleneck link. This can be used to compare default cubic to tcptuner/mpcubic.

``` bash
cd mahimahi
./start_shell
```

Now that the bottleneck link is created, we can run multiple clients within that shell:

``` bash
./start_client 5050 0 & # creates a default cubic client as a new background process
./start_client 5050 1 & # creates a tcptuner client as a new background process
./start_client 5050 2 & # creates a mpcubic client as a new background process
```

To close these:
``` bash
fg # to bring one of the background process to the foreground
Ctrl+C # repeat for each client
exit # to close the bottleneck link

pid=$(x=`sudo lsof -i :5050 -Fp` && echo ${x##p} | cut -d ' ' -f 1)
sudo kill $pid # kill any ghost process occupying port 5050
```

## Plotting congestion window size graphs

### Dependencies

First install the following packages:
```bash
sudo apt-get install iperf gnuplot texlive-font-utils
```

### Build and Load the tcp_probe Kernel Module
```bash
cd modules/tcpprobe
make
sudo insmod tcp_tuner.ko
```

### Capture Realtime Data

Use the tcp_probe kernel module to capture realtime data of:
* `cwnd` - congestion window size
* `ssthresh` - slow start threshold

```bash
# https://wiki.linuxfoundation.org/networking/tcp_testing
cd plot/data
sudo modprobe tcp_probe port=5051 full=1

iperf -p 5051 -s & # start iperf server on receiver's end
IPERFSERVER=$!

# record the captured data using one of the below techniques
sudo sysctl -w net.ipv4.tcp_congestion_control=tuner # if using CUBIC
sudo cat /proc/net/tcpprobe > cubic.dat &

sudo sysctl -w net.ipv4.tcp_congestion_control=mpcubic # if using mpCUBIC
sudo cat /proc/net/tcpprobe > mpcubic.dat &

TCPCAPTURE=$!
iperf -i 10 -t 300 -p 5051 -c 0.0.0.0 # start iperf client on sender's end

sudo kill $IPERFSERVER
sudo kill $TCPCAPTURE
```

### Plot Graphs

Plot the captured data using `gnuplot` and `epstopdf`:
```bash
cd plot
./generate_plot.sh # generates a pdf containing graphs
```
