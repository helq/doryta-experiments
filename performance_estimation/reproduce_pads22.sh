#!/usr/bin/bash -x

dorytaroot="$PWD"
dir_to_data="$dorytaroot/data/experiments/performance_estimation"

# Step 1: Training NNs and saving them as SNNs
cd "$dorytaroot"/data/models
python -m code.lenet_mnist --train --save
python -m code.lenet_mnist --train --save --fashion
python -m code.lenet_mnist --train --save --large-lenet
python -m code.lenet_mnist --train --save --fashion --large-lenet

# Step 2: Spikifying images and saving them
cd "$dorytaroot"/data/models
python -m code.ffsnn_mnist
python -m code.ffsnn_mnist --fashion

# Step 3: Simulating SNNs with spikified images (its output is used to compute statistics)
cd "$dorytaroot"/build/
mpirun -np 1 src/doryta --spike-driven --synch=3 \
    --load-model="$dorytaroot"/data/models/mnist/snn-models/lenet-mnist-filters=6,16.doryta.bin \
    --load-spikes="$dorytaroot"/data/models/mnist/spikes/spikified-mnist/spikified-images-all.bin \
    --output-dir='mnist-lenet-small' \
    --probe-firing --probe-firing-buffer=1000000 --probe-stats --probe-firing-output-only \
    --extramem=10000000 --end=10000

mpirun -np 1 src/doryta --spike-driven --synch=3 \
    --load-model="$dorytaroot"/data/models/mnist/snn-models/lenet-fashion-mnist-filters=6,16.doryta.bin \
    --load-spikes="$dorytaroot"/data/models/mnist/spikes/spikified-fashion-mnist/spikified-images-all.bin \
    --output-dir='fashion-lenet-small' \
    --probe-firing --probe-firing-buffer=1000000 --probe-stats --probe-firing-output-only \
    --extramem=10000000 --end=10000

mpirun -np 1 src/doryta --spike-driven --synch=3 \
    --load-model="$dorytaroot"/data/models/mnist/snn-models/lenet-mnist-filters=32,48.doryta.bin \
    --load-spikes="$dorytaroot"/data/models/mnist/spikes/spikified-mnist/spikified-images-all.bin \
    --output-dir='mnist-lenet-large' \
    --probe-firing --probe-firing-buffer=1000000 --probe-stats --probe-firing-output-only \
    --extramem=10000000 --end=10000

mpirun -np 1 src/doryta --spike-driven --synch=3 \
    --load-model="$dorytaroot"/data/models/mnist/snn-models/lenet-fashion-mnist-filters=32,48.doryta.bin \
    --load-spikes="$dorytaroot"/data/models/mnist/spikes/spikified-fashion-mnist/spikified-images-all.bin \
    --output-dir='fashion-lenet-large' \
    --probe-firing --probe-firing-buffer=1000000 --probe-stats --probe-firing-output-only \
    --extramem=10000000 --end=10000

# Step 4: Checking that Doryta's output/classification corresponds to keras/whetstone's
# model. Additionally, accuracy is stored in memory
rm "$dorytaroot"/tools/whetstone-mnist/ws_models
ln -s "$dorytaroot"/data/models/code "$dorytaroot"/tools/whetstone-mnist/ws_models

python "$dorytaroot"/tools/whetstone-mnist/check_doryta_inference.py \
    --path-to-keras-model "$dorytaroot"/data/models/mnist/raw_keras_models/lenet-mnist-filters=6,16 \
    --path-to-tags "$dorytaroot"/data/models/mnist/spikes/spikified-mnist/spikified-images-all.tags.bin \
    --indices-in-output 10000 \
    --outdir-doryta "$dorytaroot"/build/mnist-lenet-small \
    --dataset mnist --model-type lenet \
    --save "$dir_to_data"/small_lenet_accuracy.txt

python "$dorytaroot"/tools/whetstone-mnist/check_doryta_inference.py \
    --path-to-keras-model "$dorytaroot"/data/models/mnist/raw_keras_models/lenet-fashion-mnist-filters=6,16 \
    --path-to-tags "$dorytaroot"/data/models/mnist/spikes/spikified-fashion-mnist/spikified-images-all.tags.bin \
    --indices-in-output 10000 \
    --outdir-doryta "$dorytaroot"/build/fashion-lenet-small \
    --dataset fashion-mnist --model-type lenet \
    --save "$dir_to_data"/small_lenet_fashion_accuracy.txt

python "$dorytaroot"/tools/whetstone-mnist/check_doryta_inference.py \
    --path-to-keras-model "$dorytaroot"/data/models/mnist/raw_keras_models/lenet-mnist-filters=32,48 \
    --path-to-tags "$dorytaroot"/data/models/mnist/spikes/spikified-mnist/spikified-images-all.tags.bin \
    --indices-in-output 10000 \
    --outdir-doryta "$dorytaroot"/build/mnist-lenet-large \
    --dataset mnist --model-type lenet --shift $(( 38448 - 100 )) \
    --save "$dir_to_data"/large_lenet_accuracy.txt

python "$dorytaroot"/tools/whetstone-mnist/check_doryta_inference.py \
    --path-to-keras-model "$dorytaroot"/data/models/mnist/raw_keras_models/lenet-fashion-mnist-filters=32,48 \
    --path-to-tags "$dorytaroot"/data/models/mnist/spikes/spikified-fashion-mnist/spikified-images-all.tags.bin \
    --indices-in-output 10000 \
    --outdir-doryta "$dorytaroot"/build/fashion-lenet-large \
    --dataset fashion-mnist --model-type lenet --shift $(( 38448 - 100 )) \
    --save "$dir_to_data"/large_lenet_fashion_accuracy.txt

# Step 5: Aggregating leak, integrate and fire operation usage per neuron into groups.
# Echa group corresponds to a crossbar connection
cd "$dorytaroot/build/"
python "$dorytaroot"/tools/general/total_stats.py \
    --path mnist-lenet-small \
    --iterations 10000 --csv "$dorytaroot"/data/experiments/performance_estimation/small_lenet \
    --groups '[784,784,784,784,784,784,784,196,196,196,196,196,196,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,120,84]'

python "$dorytaroot"/tools/general/total_stats.py \
    --path fashion-lenet-small \
    --iterations 10000 --csv "$dorytaroot"/data/experiments/performance_estimation/small_lenet_fashion \
    --groups '[784,784,784,784,784,784,784,196,196,196,196,196,196,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,120,84]'

python "$dorytaroot"/tools/general/total_stats.py \
    --path mnist-lenet-large \
    --iterations 10000 --csv "$dorytaroot"/data/experiments/performance_estimation/large_lenet \
    --groups '[784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,120,84]'

python "$dorytaroot"/tools/general/total_stats.py \
    --path fashion-lenet-large \
    --iterations 10000 --csv "$dorytaroot"/data/experiments/performance_estimation/large_lenet_fashion \
    --groups '[784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,120,84]'

# Bonus step: Saves info shown in Table 6
cd "$dir_to_data"

truncate -s 0 table6.csv # deleting/creating file
echo "workload,integration,fire,accuracy" >> table6.csv
for f in {small_lenet,small_lenet_fashion,large_lenet,large_lenet_fashion}; do
    # saving workload name
    printf "$f," >> table6.csv
    # saving integration and fire stats
    awk -F, 'NR == 2 { printf "%s,%f,", $4, $5 }' $f-average.csv >> table6.csv
    # saving accuracy stats
    cat ${f}_accuracy.txt >> table6.csv
done

# Step 6: Producing Table 7 and Figure 7
python "$dorytaroot/external/tools/performance spintronics estimation"/benchmarking.py \
    --path-ll "$dir_to_data"/large_lenet-average.csv \
    --path-sl "$dir_to_data"/small_lenet-average.csv \
    --path-llf "$dir_to_data"/large_lenet_fashion-average.csv \
    --path-slf "$dir_to_data"/small_lenet_fashion-average.csv \
    --output "$dir_to_data"/combine
