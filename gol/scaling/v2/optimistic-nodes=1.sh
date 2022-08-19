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
np=64

outdir=gol-$grid_width-random-spike-np=$np
mkdir -p $outdir

# running code
mpirun --bind-to core -np 64 --report-bindings -vvv \
    "$DORYTA_BIN" --synch=3 --spike-driven \
        --max-opt-lookahead=10 \
        --gvt-interval=512 \
        --gol-model --gol-model-size=$grid_width \
        --heartbeat=20 --end=40000.2 \
        --random-spikes-time=5.0 \
        --random-spikes-uplimit=$((grid_width * grid_width)) \
        --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
