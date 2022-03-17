#!/usr/bin/env bash

ROOT_DORYTA=..
MODELS_DIR="$ROOT_DORYTA"/data/models
TOOLS_DIR="$ROOT_DORYTA"/tools

mkdir -p gol-random/output

tar -xf $MODELS_DIR/gol-spikes/20x20/gol-random.tar.xz -C gol-random

for file in gol-random/gol-random/*.bin; do
  plain_name=${file%.bin}
  src/doryta --gol-model --load-spikes=$file --spike-driven \
    --output-dir=gol-random/output/${plain_name##*/} --extramem=10000 \
    --probe-stats --end=100.5 #--probe-firing --probe-firing-buffer=40000
done

mkdir -p gol-random/aggregated
python "$TOOLS_DIR"/general/aggregate_stats.py --path 'gol-random/output/gol-random-*' \
  --save gol-random/aggregated
python "$TOOLS_DIR"/general/total_stats.py --path gol-random --groups '[400,400]' \
  --iterations $((200 * 1000)) --csv 'gol-random/aggregated'
