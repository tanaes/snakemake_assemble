#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "script.sh <out_dir (with config.yaml)> [additional snakemake arguments]*"
    exit
fi

outdir=$1

mkdir -p $outdir/cluster_logs

#source activate snakemake_assemble 
export PATH=$PATH:$(pwd)/bin:$(pwd)/bin/scripts

snakemake -j 16 --local-cores 4 -w 90 --cluster-config cluster.json --cluster "qsub -V -e {cluster.error} -o {cluster.output} -m n -l nodes=1:ppn={cluster.n} -l mem={cluster.mem}gb -l walltime={cluster.time}" --directory "$@" all phylophlan_all

#source deactivate
