#!/usr/bin/bash

# Execution example:
# ./run-sbatch-script.sh gol-experiments-v2 v2/conservative-nodes=1.sh

home=/gpfs/u/home/SPNR/SPNRcrzc
base_experiments_path="$home/scratch/doryta-experiments"
path_to_doryta_bin="$home/barn/doryta/build/src/doryta"

# Checking for validity of input
if [ ! $# -eq 2 ]; then
  echo "This script requires TWO arguments: the relative directory to store all" \
       "experiments results, and the sbatched script."
  exit 1
fi
if [ -z "$2" ]; then
  echo "The script given is empty!"
  exit 1
fi

# Finding out paths and
script_file="$2"
experiments_name="$(basename -s .sh "$script_file")"
experiments_path="$base_experiments_path/$1/$experiments_name"

if [ -d "$experiments_path" ]; then
  echo "Warning! Experiments directory already exists. Preventing script from executing"
  echo "Directory:" '"'"$experiments_path"'"'
  exit 1
fi

mkdir -p "$experiments_path" || exit 1

sbatch -D "$experiments_path" "$script_file" "$path_to_doryta_bin"
