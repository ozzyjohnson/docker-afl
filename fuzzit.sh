#!/bin/bash

# Use all available CPUs by default.
NUM_FUZZERS=`getconf _NPROCESSORS_ONLN`

# In and Out directories.
IN_DIR=in_dir
OUT_DIR=out_dir
DATA_DIR=~/

# Target binary.
FUZZ_TARGET=/opt/libjpeg-turbo/bin/djpeg

# Fuzzer ID prefix.
FUZZ_ID=afl

# AFL image.
AFL_IMAGE=ozzyjohnson/afl

# Help printer.
function help {
    echo "Usage: fuzz.sh [OPTION]"
    echo "Launch a team of fuzzers. Uses the number of available cores"
    echo "by default."
    echo " "
    echo "-i            input directory"
    echo "-o            output directory"
    echo "-n            number of fuzzers to launch"
    echo "-f            fuzz target"
    echo "-t            fuzz ID convention"
    echo "-d            data directory to be mapped to containers"
}

# Simple command line argument handling.
while getopts ':o:i:n:d:t:f' flag
    
do
    case $flag in
        i) IN_DIR=$OPTARG;;
        o) OUT_DIR=$OPTARG;;
        n) NUM_FUZZERS=$OPTARG;;
        f) FUZZ_TARGET=$OPTARG;;
        t) FUZZ_ID=$OPTARG;;
        d) DATA_DIR=$OPTARG;;
        \?) help; exit 2;;
    esac
done

sudo docker run -v $DATA_DIR:/data -d --name=${FUZZ_ID}1 \
  $AFL_IMAGE \
  afl-fuzz -i $IN_DIR -o $OUT_DIR -S ${FUZZ_ID}1 -D $FUZZ_TARGET

for i in `seq 2 $NUM_FUZZERS`; do
    sudo docker run -v $DATA_DIR:/data -d --name=${FUZZ_ID}${i} \
      $AFL_IMAGE \
      afl-fuzz -i $IN_DIR -o $OUT_DIR -S ${FUZZ_ID}${i} $FUZZ_TARGET
done