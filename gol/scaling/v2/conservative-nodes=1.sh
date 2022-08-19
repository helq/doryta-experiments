#!/usr/bin/bash -x

# loading modules
module load xl_r spectrum-mpi/10.4

# checking some number of cpus parameters
lscpu
grep -c processor /proc/cpuinfo

# variables and pre-loading everything
DORYTA_BIN=/gpfs/u/home/SPNR/SPNRcrzc/barn/doryta/build/src/doryta

# second part
grid_width=1024

for np in {40,32,16,8,4,2,1}; do
    outdir=gol-$grid_width-random-spike-np=$np
    mkdir -p $outdir
    
    # running code
    mpirun --bind-to core -np $np \
        "$DORYTA_BIN" --synch=2 --spike-driven \
            --cons-lookahead=4.0 \
            --gvt-interval=512 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=20 --end=40000.2 \
            --random-spikes-time=5.0 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
done
