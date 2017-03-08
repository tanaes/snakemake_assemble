#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "script.sh <out_dir (with config.yaml)> [additional snakemake arguments]*"
    exit
fi

outdir=$@

mkdir $outdir/cluster_logs

snakemake -j 16 --local-cores 4 -w 90 --cluster-config cluster.json --cluster "qsub -e $outdir/cluster_logs/{rule}_{wildcards.sample}.err -o $outdir/cluster_logs/{rule}_{wildcards.sample}.out -m n -l nodes=1:ppn={cluster.n} -l mem={cluster.mem}gb -l walltime={cluster.time}" --directory "$@"

