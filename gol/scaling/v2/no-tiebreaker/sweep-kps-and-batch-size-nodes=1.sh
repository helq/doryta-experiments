#!/usr/bin/bash -x
#SBATCH --nodes=1
#SBATCH --gres=gpu:6
#SBATCH -t 240

# loading modules
module load xl_r spectrum-mpi/10.4

# variables and pre-loading everything
DORYTA_BIN="$1.no-tiebreaker"
grid_width=1024
np=32

#for kp in {4,8,16,32,64,128,256,512,1024,2048,4096,8192}; do
for kp in {4,8,16,32,64,128,256,512,1024,2048}; do
  for batch in {4,8,16,32,64,128,256,512,1024,2048}; do
    # conservative
    outdir=conservative/gol-$grid_width-random-spike-np=$np-kps=$kp-batch=$batch
    mkdir -p $outdir
    mpirun --bind-to core -np $np \
        "$DORYTA_BIN" --synch=2 --spike-driven \
            --batch=$batch --nkp=$kp \
            --cons-lookahead=1.0 \
            --gvt-interval=512 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=20 --end=40000.2 \
            --random-spikes-time=5.0 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((6 * grid_width * grid_width / np)) > $outdir/model-result.txt

    # optimistic
    outdir=optimistic/gol-$grid_width-random-spike-np=$np-kps=$kp-batch=$batch
    mkdir -p $outdir
    mpirun --bind-to core -np $np \
        "$DORYTA_BIN" --synch=3 --spike-driven \
            --batch=$batch --nkp=$kp \
            --max-opt-lookahead=10 \
            --gvt-interval=100000 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=20 --end=40000.2 \
            --random-spikes-time=5.0 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((6 * grid_width * grid_width / np)) > $outdir/model-result.txt
  done
done
