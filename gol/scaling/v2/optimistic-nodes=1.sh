#!/usr/bin/bash -x

# setting up SLURM
if [ "x$SLURM_NPROCS" = "x" ]
then
  if [ "x$SLURM_NTASKS_PER_NODE" = "x" ]
  then
    SLURM_NTASKS_PER_NODE=1
  fi
  SLURM_NPROCS=`expr $SLURM_JOB_NUM_NODES \* $SLURM_NTASKS_PER_NODE`
else
  if [ "x$SLURM_NTASKS_PER_NODE" = "x" ]
  then
    SLURM_NTASKS_PER_NODE=`expr $SLURM_NPROCS / $SLURM_JOB_NUM_NODES`
  fi
fi

srun hostname -s | sort -u > /tmp/hosts.$SLURM_JOB_ID
grep -q 'release 7\.' /etc/redhat-release
if [ $? -eq 0 ]; then
  net_suffix=-ib
fi
awk "{ print \$0 \"$net_suffix slots=$SLURM_NTASKS_PER_NODE\"; }" /tmp/hosts.$SLURM_JOB_ID >/tmp/tmp.$SLURM_JOB_ID
mv /tmp/tmp.$SLURM_JOB_ID /tmp/hosts.$SLURM_JOB_ID

# loading modules
module load xl_r spectrum-mpi/10.4

# variables and pre-loading everything
DORYTA_BIN=/gpfs/u/home/SPNR/SPNRcrzc/barn/doryta/build/src/doryta

# second part
grid_width=1000

for np in {2,4,8,16,32,40}; do
    outdir=gol-$grid_width-random-spike-np=$np
    mkdir -p $outdir
    
    # optimistic
    mpirun --bind-to core -hostfile /tmp/hosts.$SLURM_JOB_ID -np $np \
        "$DORYTA_BIN" --synch=3 --spike-driven \
            --max-opt-lookahead=1 \
            --gol-model --gol-model-size=$grid_width \
            --heartbeat=1 --end=2000.2 \
            --random-spikes-time=0.6 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt

    # optimistic realtime
    # mpirun --bind-to core -hostfile /tmp/hosts.$SLURM_JOB_ID -np $np \
    #     "$DORYTA_BIN" --synch=5 --spike-driven \
    #         --max-opt-lookahead=1 \
    #         --gvt-interval=1 --batch=4 \
    #         --gol-model --gol-model-size=$grid_width --end=1000.2 \
    #         --random-spikes-time=0.6 \
    #         --random-spikes-uplimit=$((grid_width * grid_width)) \
    #         --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
done

# cleaning SLURM
rm /tmp/hosts.$SLURM_JOB_ID
