#!/usr/bin/env bash

#ROOT_DORYTA=..
#MODELS_DIR="$ROOT_DORYTA"/data/models
DORYTA_BIN=/gpfs/u/home/SPNR/SPNRcrzc/barn/doryta/build/src/doryta

# OLD code (used spikes stored in memory)
# storing results
# mpirun -np 40 src/doryta --synch=2 --spike-driven \
#     --gol-model --gol-model-size=1000 \
#     --load-spikes="$MODELS_DIR"/gol/1000x1000/gol-random-3287591.bin \
#     --end=1000.2 --probe-stats --probe-firing --probe-firing-buffer=5000000 \
#     --output-dir=gol-1000-random-3287591 --extramem=1000000
#
# for np in {1,2,4,8,16,32,40}; do
#     outdir=gol-1000-random-np=$np
#     mkdir -p $outdir
#     mpirun -np $np src/doryta --synch=2 --spike-driven \
#         --gol-model --gol-model-size=1000 --end=1000.2 \
#         --load-spikes="$MODELS_DIR"/gol/1000x1000/gol-random-3287591.bin \
#         --output-dir= --extramem=$((40000000 / np)) > $outdir/model-result.txt
# done

for np in {1,2,4,8,16,32,40}; do
    outdir=gol-$grid_width-random-spike-np=$np
    mkdir -p $outdir
    
    mpirun --bind-to core -hostfile /tmp/hosts.$SLURM_JOB_ID -np $np \
        "$DORYTA_BIN" --synch=2 --spike-driven \
            --gol-model --gol-model-size=$grid_width --end=1000.2 \
            --random-spikes-time=0.6 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
done
