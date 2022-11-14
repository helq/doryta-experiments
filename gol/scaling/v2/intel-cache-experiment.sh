#!/usr/bin/bash -x

# This script is not to be run in AiMOS. Rather, it should be run in an Intel Xeon
# processor.

DORYTA_BIN="$1"
grid_width=1024

outdir=gol-$grid_width-random-spike-optimistic
mkdir -p $outdir

# conservative run
for np in {16,8,4,2}; do
    /home/chrisc/PROJECTS/PCM/pcm-build/bin/pcm -- mpirun --bind-to core -np $np \
        "$DORYTA_BIN" --synch=3 --spike-driven \
            --cons-lookahead=4.0 \
            --gvt-interval=512 \
            --clock-rate=2100000000 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=20 --end=4000.2 \
            --random-spikes-time=5.0 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
done

outdir=gol-$grid_width-random-spike-optimistic
mkdir -p $outdir

# optimistic run
for np in {16,8,4,2}; do
    /home/chrisc/PROJECTS/PCM/pcm-build/bin/pcm -- mpirun --bind-to core -np $np \
        "$DORYTA_BIN" --synch=3 --spike-driven \
            --max-opt-lookahead=10 \
            --gvt-interval=512 \
            --clock-rate=2100000000 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=20 --end=4000.2 \
            --random-spikes-time=5.0 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result-$np.txt
done
