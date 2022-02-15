#!/usr/bin/bash -x

# to run: sbatch -N 32 --ntasks-per-node=40 --gres=gpu:6 -t 30 -D /gpfs/u/home/SPNR/SPNRcrzc/scratch/doryta-experiments/gol-experiments-huge /gpfs/u/home/SPNR/SPNRcrzc/barn/doryta/build/gol-experiments-huge/large-gol-10000^2-32-nodes.sh

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

## running code
np=$SLURM_NPROCS
grid_width=10000

outdir=gol-$grid_width-random-spike-np=$np
mkdir -p $outdir

mpirun --bind-to core -hostfile /tmp/hosts.$SLURM_JOB_ID -np $np \
    "$DORYTA_BIN" --synch=2 --spike-driven \
        --gol-model --gol-model-size=$grid_width --end=1000.2 \
        --random-spikes-time=0.6 \
        --random-spikes-uplimit=$((grid_width * grid_width)) \
        --output-dir=$outdir --extramem=10000000 # > $outdir/model-result.txt

# Running small example on an increasing amount of nodes
grid_width=1000

for i in {1..32}; do
    np=$((i * 40))
    outdir=gol-$grid_width-random-spike-np=$np
    mkdir -p $outdir
    
    # running code
    mpirun --bind-to core -hostfile /tmp/hosts.$SLURM_JOB_ID -np $np \
        "$DORYTA_BIN" --synch=2 --spike-driven \
            --gol-model --gol-model-size=$grid_width --end=1000.2 \
            --random-spikes-time=0.6 \
            --random-spikes-uplimit=$((grid_width * grid_width)) \
            --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
done

# cleaning SLURM
rm /tmp/hosts.$SLURM_JOB_ID
