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
np=32

for batch in {4,8,16,32,64,128,256,512,1024,2048}; do
    outdir=gol-$grid_width-random-spike-np=$np-batch=$batch
    mkdir -p $outdir
    
    # running code
    mpirun --bind-to core -np $np \
        "$DORYTA_BIN" --synch=3 --spike-driven \
            --batch=$batch \
            --max-opt-lookahead=10 \
            --gvt-interval=512 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=20 --end=40000.2 \
            --random-spikes-time=5.0 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
done
