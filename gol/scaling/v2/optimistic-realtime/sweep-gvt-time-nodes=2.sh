#!/usr/bin/bash -x
#SBATCH --nodes=2
#SBATCH --ntasks=64
#SBATCH --gres=gpu:6
#SBATCH -t 120

# loading modules
module load xl_r spectrum-mpi/10.4

# variables and pre-loading everything
DORYTA_BIN="$1"
grid_width=1024
np=64

for gvt in {1,2,3,4,5,6,7,8}; do
    outdir=gol-$grid_width-gvt=$gvt
    mkdir -p $outdir
    mpirun --bind-to core -np $np \
        "$DORYTA_BIN" --synch=5 --spike-driven \
            --max-opt-lookahead=10 \
            --gvt-interval=$gvt \
            --nkp=32 --batch=64 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=20 --end=40000.2 \
            --random-spikes-time=5.0 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
done
