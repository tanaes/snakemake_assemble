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

snakemake --cores 200 --resources disc=20 --local-cores 4 -w 60 --cluster-config cluster.json --cluster "qsub -V {cluster.queue} -k eo -m n -l nodes=1:ppn={cluster.n} -l mem={cluster.mem}gb -l walltime={cluster.time} -e {cluster.error} -o {cluster.output}" --directory "$@" $add_args

source deactivate
