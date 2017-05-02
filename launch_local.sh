#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "script.sh <out_dir (with config.yaml)> [additional snakemake arguments]*"
    exit
fi

add_args=""
if [ "$#" -lt 2 ]; then
    add_args="all"
    #TODO solve the problem with two-step pipeline run
    #add_args="all phylophlan_all"
fi

outdir=$1

mkdir -p $outdir/cluster_logs

export PATH=$PATH:$(pwd)/bin:$(pwd)/bin/scripts

if [ -d $(pwd)/bin/pplacer ] ; then
    export PATH=$PATH:$(pwd)/bin/pplacer/
fi

snakemake -j 4 --resources disc=20 -w 60 --directory "$@" $add_args

### Use for dry run
#snakemake -j 1 -n -r --directory "$@" $add_args
