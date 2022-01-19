#!/usr/bin/env bash

ROOT_DORYTA=..
MODELS_DIR="$ROOT_DORYTA"/data/models
TOOLS_DIR="$ROOT_DORYTA"/tools

# mpirun -np 40 src/doryta --synch=2 --spike-driven \
#     --gol-model --gol-model-size=1000 \
#     --load-spikes="$MODELS_DIR"/gol/1000x1000/gol-random-3287591.bin \
#     --end=1000.2 --probe-stats --probe-firing --probe-firing-buffer=5000000 \
#     --output-dir=gol-1000-random-3287591 --extramem=1000000

for np in {1,2,4,8,16,32,40}; do
    outdir=gol-1000-random-np=$np
    mkdir -p $outdir
    mpirun -np $np src/doryta --synch=2 --spike-driven \
        --gol-model --gol-model-size=1000 --end=1000.2 \
        --load-spikes="$MODELS_DIR"/gol/1000x1000/gol-random-3287591.bin \
        --output-dir= --extramem=$((40000000 / np)) > $outdir/model-result.txt
done
