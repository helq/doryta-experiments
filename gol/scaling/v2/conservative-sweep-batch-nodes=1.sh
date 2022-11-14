#!/usr/bin/bash -x
#SBATCH --nodes=1
#SBATCH --gres=gpu:6
#SBATCH -t 240

# loading modules
module load xl_r spectrum-mpi/10.4

# variables and pre-loading everything
DORYTA_BIN="$1"

# second part
grid_width=1024
np=32

for batch in {4,8,16,32,64,128,256,512,1024,2048}; do
    for gvt in {128,256,512,1024,2048,4096}; do
        outdir=gol-$grid_width-np=$np-batch=$batch-gvt=$gvt
        mkdir -p $outdir
        
        # running code
        mpirun --bind-to core -np $np \
            "$DORYTA_BIN" --synch=2 --spike-driven \
                --cons-lookahead=4.0 \
                --gvt-interval=$gvt --batch=$batch \
                --gol-model --gol-model-size=$grid_width \
                --heartbeat=20 --end=40000.2 \
                --random-spikes-time=5.0 \
                --random-spikes-uplimit=$((grid_width * grid_width)) \
                --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
    done
done
