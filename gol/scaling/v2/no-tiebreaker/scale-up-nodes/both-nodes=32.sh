#!/usr/bin/bash -x
#SBATCH --nodes=32
#SBATCH --ntasks=1024
#SBATCH --gres=gpu:6
#SBATCH -t 15

# loading modules
module load xl_r spectrum-mpi/10.4

# variables and pre-loading everything
DORYTA_BIN="$1.no-tiebreaker"
np=1024

for grid_width in {1024,2048,4096,8192}; do
    outdir=conservative/gol-$grid_width-np=$np
    mkdir -p $outdir
    mpirun --bind-to core -np $np --report-bindings -vvv \
        "$DORYTA_BIN" --synch=2 --spike-driven \
            --cons-lookahead=4.0 \
            --gvt-interval=512 --batch=512 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=20 --end=40000.2 \
            --random-spikes-time=5.0 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((40000 * grid_width / np)) > $outdir/model-result.txt

    outdir=optimistic/gol-$grid_width-np=$np
    mkdir -p $outdir
    mpirun --bind-to core -np $np --report-bindings -vvv \
        "$DORYTA_BIN" --synch=3 --spike-driven \
            --max-opt-lookahead=10 \
            --gvt-interval=1000000 --nkp=16 --batch=64 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=20 --end=40000.2 \
            --random-spikes-time=5.0 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((10 * grid_width * grid_width / np)) > $outdir/model-result.txt
done
