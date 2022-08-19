#!/usr/bin/bash -x
#SBATCH --nodes=1
#SBATCH --gres=gpu:6
#SBATCH -t 120

# loading modules
module load xl_r spectrum-mpi/10.4

# variables and pre-loading everything
DORYTA_BIN="$1"
grid_width=1024
np=32

# running code
for levels in {1,3,7,15,31,63,127,255,511,1023}; do
    # conservative
    outdir=gol-$grid_width-random-spike-np=$np-levels=$levels-conservative
    mkdir -p $outdir
    mpirun --bind-to core -np $np \
        "$DORYTA_BIN" --synch=2 --spike-driven \
            --spike-rand-sched=$levels \
            --cons-lookahead=0.000001 \
            --gvt-interval=512 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=20 --end=40000.000001 \
            --random-spikes-time=1.0 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
    
    # optimistic
    outdir=gol-$grid_width-random-spike-np=$np-levels=$levels-optimistic
    mkdir -p $outdir
    mpirun --bind-to core -np $np \
        "$DORYTA_BIN" --synch=3 --spike-driven \
            --spike-rand-sched=$levels \
            --max-opt-lookahead=10 \
            --gvt-interval=512 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=20 --end=40000.000001 \
            --random-spikes-time=1.0 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt

    # optimistic 2 - increasing lookahead with the number of levels
    # lookahead=$levels
    # heartbeat=$levels
    # outdir=gol-$grid_width-random-spike-np=$np-levels=$levels-lookahead=$lookahead-heartbeat=$heartbeat-optimistic-varying-lookahead
    # mkdir -p $outdir
    # mpirun --bind-to core -np $np \
    #     "$DORYTA_BIN" --synch=3 --spike-driven \
    #         --spike-rand-sched=$levels \
    #         --max-opt-lookahead=$lookahead \
    #         --heartbeat=$heartbeat --end=$((heartbeat * 20000)).2 \
    #         --gvt-interval=512 \
    #         --gol-model --gol-model-size=$grid_width \
    #         --random-spikes-time=1.0 \
    #         --random-spikes-uplimit=$((grid_width * grid_width)) \
    #         --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt

    # optimistic 3 - forcing the lookahead to stay the same as the heartbeat interval
    # outdir=gol-$grid_width-random-spike-np=$np-levels=$levels-optimistic-lookahead-same-as-heartbeat
    # mkdir -p $outdir
    # mpirun --bind-to core -np $np \
    #     "$DORYTA_BIN" --synch=3 --spike-driven \
    #         --spike-rand-sched=$levels \
    #         --max-opt-lookahead=20 \
    #         --gvt-interval=512 \
    #         --gol-model --gol-model-size=$grid_width \
    #         --heartbeat=20 --end=40000.2 \
    #         --random-spikes-time=1.0 \
    #         --random-spikes-uplimit=$((grid_width * grid_width)) \
    #         --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
done
