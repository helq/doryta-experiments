# Performance estimation processing data

This folder contains the aggregated statistics of SNNs simulated in Doryta. This data is
used by another script to estimate the energy consumption of the SNNs implemented in
spintronic-based and CMOS devices (check the directory
`<doryta-root>/external/performance spintronics estimation` for the script used in the
energy, latency and area estimation).

## Procedure example to generate a single file

To obtain the results here presented, execute the following commands:

*Notice that we assume `<doryta-root>/` to be the root directory for Doryta's repository.*

1. (optional) Train the SNN model using Keras and Whetstone:

    Depending on the model, you might have to modify the code directly (and switch on/off
    some variables) or just pass the necessary parameters to the script. The
    inconsistencies arised from the fact that this is experimental code. Only some scripts
    have been modified to receive parameters from the user as to make the process of
    replicating the results from the paper. It should not be difficult to flip the
    necessary switches to train/load or save the models. Thank you for reading though `<3`

    ```bash
    # Edit file <doryta-root>/data/models/code/ffsnn_mnist.py for Fully connected network
    cd <doryta-root>/data/models
    python -m code.ffsnn_minst
    # Or run LeNet with one of many parameters
    python -m code.lenet_mnist --help
    python -m code.lenet_mnist
    python -m code.lenet_mnist --train --save --fashion --large-lenet
    ```

    If the right switches are selected within `ffsnn_mnist.py`, a SNN trained in MNIST
    should be generated as a `.doryta.bin` file under the directory
    `<doryta-root>/data/models/mnist/snn-models/`. This file is readable by Doryta as a
    model.

    Additionally, if the switch `saving_model` is turned on, the MNIST dataset will be
    saved as a set of spikes that can be read by Doryta. They will stored in a subfolder
    called `<doryta-root>/data/models/mnist/spikes/spikified-mnist/`.

2. Run the SNN model in Doryta and tell Doryta to store the stats:

    ```bash
    mpirun -np 1 <path-to-bin>/doryta --spike-driven \
        --load-model=<doryta-root>/data/models/mnist/snn-models/ffsnn-mnist.doryta.bin \
        --load-spikes=<doryta-root>/data/models/mnist/spikes/spikified-mnist/spikified-images-all.bin \
        --output-dir='ffsnn-all' \
        --probe-firing --probe-firing-buffer=100000 --probe-stats \
        --extramem=10000000 --end=10000
    ```

    If Doryta fails to run and the reason is `--extramem`, increase the size of
    extramemory and try again.

3. (optional) Check that Doryta's output corresponds 1-to-1 to that of the Keras model
    that it is based on:

    ```bash
    python <doryta-root>/tools/whetstone-mnist/check_doryta_inference.py \
        --path-to-keras-model <doryta-root>/data/models/mnist/raw_keras_models/ffsnn-mnist \
        --path-to-tags <doryta-root>/data/models/mnist/spikes/spikified-mnist/spikified-images-all.tags.bin \
        --indices-in-output 10000 \
        --outdir-doryta <path-to-output>/ffsnn-all \
        --dataset fashion-mnist --model-type lenet
    ```

    The result of running this script should be a positive message on the screen informing
    you that the output from Keras and Doryta are identical.

4. Finally, to create the files containing the information here present run:

    ```bash
    python <doryta-root>/tools/general/total_stats.py \
        --path <path-to-output>/ffsnn-all \
        --iterations 10000 --groups '[784,256,64]' \
        --csv fully-connected-mnist
    ```

    Note that the `.csv`s generated by this step are missing a couple of columns present
    in the `.ods` files found in this folder. All `.ods` files are the result of adding by
    hand several columns that determine the number of connections/synapses per layer.

    The `--groups` parameters for other network architectures are:

    * For GoL (20 by 20 grid):

        ```
        '[400,400]'
        ```

    * For (small) LeNet:

        ```
        '[784,784,784,784,784,784,784,196,196,196,196,196,196,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,120,84]'
        ```

    * For large LeNet:

        ```
        '[784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,784,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,196,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,120,84]'
        ```

        (yeah, it gets a bit out of hand when the network architecture is laaarge :S)
