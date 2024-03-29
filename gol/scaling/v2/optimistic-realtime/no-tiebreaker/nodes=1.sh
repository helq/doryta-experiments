#!/usr/bin/bash -x
#SBATCH --nodes=1
#SBATCH --gres=gpu:6
#SBATCH -t 240

# loading modules
module load xl_r spectrum-mpi/10.4

# variables and pre-loading everything
DORYTA_BIN="$1.no-tiebreaker"
grid_width=1024

# running code
for np in {32,16,8,4,2,1}; do
    outdir=gol-$grid_width-random-spike-np=$np
    mkdir -p $outdir

    mpirun --bind-to core -np $np --report-bindings -vvv \
        "$DORYTA_BIN" --synch=5 --spike-driven \
            --max-opt-lookahead=10 \
            --gvt-interval=1 \
            --nkp=4 --batch=64 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=20 --end=40000.2 \
            --random-spikes-time=5.0 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
done
