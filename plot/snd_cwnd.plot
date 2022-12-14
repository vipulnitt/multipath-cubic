set terminal postscript eps color size 13,8
set output "snd_cwnd_plot.eps"
set multiplot layout 2,1 title "TCP cwnd_send development"

set xtics nomirror
set ytics nomirror

set key right bottom

set grid linecolor rgb "black"

#set style line 1 lt 1 lw 2 pt 7 
#set style line 2 lt 1 lw 2 pt 9

#show timestamp
set xlabel "time (seconds)"
set ylabel "segments (cwnd, ssthresh)"

# Congestion control send window
set title "CUBIC on 1Mbit/1Mbit/50ms/50ms"
plot "data/cubic.dat" using 1:7 title "snd_cwnd" with linespoints, \
  "data/cubic.dat" using 1:($8>=2147483647 ? 0 : $8) title "snd_ssthresh" with linespoints

set xrange [0:100]
set title "mpCUBIC on 1Mbit/1Mbit/50ms/50ms"
plot "data/mpcubic.dat" using 1:7 title "snd_cwnd" with linespoints, \
  "data/mpcubic.dat" using 1:($8>=2147483647 ? 0 : $8) title "snd_ssthresh" with linespoints
