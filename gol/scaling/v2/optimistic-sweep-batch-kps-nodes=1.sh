#!/usr/bin/bash -x
#SBATCH --nodes=1
#SBATCH --gres=gpu:6
#SBATCH -t 240

# loading modules
module load xl_r spectrum-mpi/10.4

# variables and pre-loading everything
DORYTA_BIN="$1"
grid_width=1024
np=32

for kp in {4,8,16,32,64,128,256,512,1024}; do
    for batch in {4,8,16,32,64,128,256,512,1024,2048}; do
        outdir=gol-$grid_width-np=$np-batch=$batch-kp=$kp
        mkdir -p $outdir
        
        # running code
        mpirun --bind-to core -np $np \
            "$DORYTA_BIN" --synch=3 --spike-driven \
                --batch=$batch --nkp=$kp \
                --max-opt-lookahead=10 \
                --gvt-interval=1000000 \
                --gol-model --gol-model-size=$grid_width \
                --heartbeat=20 --end=40000.2 \
                --random-spikes-time=5.0 \
                --random-spikes-uplimit=$((grid_width * grid_width)) \
                --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
    done
done
