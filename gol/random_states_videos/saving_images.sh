#!/usr/bin/env bash

python tools/gol/show_state.py --path build/gol-100-random-3287590 \
  --size=100 --speed 50 --save-as gol-100-random-3287590

python tools/gol/show_state.py --path build/gol-1000-random-3287591 \
  --size=1000 --speed 50 --save-as gol-1000-random-3287591
