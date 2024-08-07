#!/usr/bin/bash -x
#SBATCH --nodes=1
#SBATCH --gres=gpu:6
#SBATCH -t 240

# loading modules
module load xl_r spectrum-mpi/10.4

# variables and pre-loading everything
DORYTA_BIN="$1"

for np in {32,16,8,4}; do
  for grid_width in {128,1024}; do
      diehard2500="$DORYTA_MODELS/gol/spikes/${grid_width}x${grid_width}/gol-die-hard-2500.bin"

      outdir=conservative/gol-$grid_width-np=${np}-spike-driven
      mkdir -p $outdir
      mpirun --bind-to core -np $np \
          "$DORYTA_BIN" --synch=2 --spike-driven \
              --gvt-interval=128 --batch=512 \
              --gol-model --gol-model-size=$grid_width \
              --end=2501.2 \
              --load-spikes="$diehard2500" \
              --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt

      outdir=conservative/gol-$grid_width-np=${np}-needy
      mkdir -p $outdir
      mpirun --bind-to core -np $np \
          "$DORYTA_BIN" --synch=2 \
              --gvt-interval=128 --batch=512 \
              --gol-model --gol-model-size=$grid_width \
              --end=2501.2 \
              --load-spikes="$diehard2500" \
              --output-dir=$outdir --extramem=$((40000000 / np)) > $outdir/model-result.txt
  done
done
