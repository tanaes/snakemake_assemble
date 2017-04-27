#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "script.sh <out_dir (with config.yaml)> [additional snakemake arguments]*"
    exit
fi

add_args=""
if [ "$#" -lt 2 ]; then
    add_args="all phylophlan_all"
fi

outdir=$1

mkdir -p $outdir/cluster_logs

source activate snakemake_assemble 
export PATH=$PATH:$(pwd)/bin:$(pwd)/bin/scripts

snakemake -j 16 --local-cores 4 -w 90 --cluster-config cluster.json --cluster "touch {cluster.output}; " --directory "$@" $add_args
#snakemake -j 1 -n -r --directory "$@" phylophlan_all
source deactivate 
