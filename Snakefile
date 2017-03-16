import os
import tempfile

configfile: "config.yaml"

ENV = config["env"]

shell.prefix("set +u; " + ENV + "; set -u; ")

TMP_DIR_ROOT = config['tmp_dir_root']

samples = config["samples"]

snakefiles = os.path.join(config["software"]["snakemake_folder"],
                          "bin/snakefiles/")

include: snakefiles + "simplify_fasta.py"

include: snakefiles + "folders"
include: snakefiles + "raw"
include: snakefiles + "qc"
include: snakefiles + "assemble"
include: snakefiles + "map"
include: snakefiles + "bin"
include: snakefiles + "anvio"
include: snakefiles + "clean"
include: snakefiles + "test"
include: snakefiles + "util"

rule all:
    # raw
    input:
        expand(data_dir + "{sample}/{sample}_links.done", sample=samples),
    # QC
        expand(qc_dir + "{sample}/skewer_trimmed/{sample}.trimmed.R1.fastq.gz", sample=samples),
        expand(qc_dir + "{sample}/skewer_trimmed/{sample}.trimmed.R2.fastq.gz", sample=samples),
        expand(qc_dir + "{sample}/filtered/{sample}.R1.trimmed.filtered.fastq.gz", sample=samples),
        expand(qc_dir + "{sample}/filtered/{sample}.R2.trimmed.filtered.fastq.gz", sample=samples),
        qc_dir + "multiQC_per_sample/multiqc_report.html",
    # Assembly
        expand(assemble_dir + "{sample}/{assembler}/{sample}.contigs.fa",
               sample=samples, assembler=config['assemblers']),
        expand(assemble_dir + "{sample}/metaquast.tar.gz",
               sample=samples),
        expand(assemble_dir + "{sample}/quast.tar.gz",
               sample=samples),
    # Mapping
        # expand(map_dir + "{bin_sample}/mapping/{bin_sample}_{abund_sample}.cram",
        #        sample=samples, bin_sample=config['binning_samples'],
        #        abund_sample=config['abundance_samples']),
    # Binning
        expand(bin_dir + "{bin_sample}/abundance_files/{bin_sample}_abund_list.txt",
               bin_sample=config['binning_samples']),
        expand(bin_dir + "{bin_sample}/maxbin/{bin_sample}.summary",
               bin_sample=config['binning_samples']),
    # Anvio
        expand(anvio_dir + "{bin_sample}/{bin_sample}_samples-summary_CONCOCT.tar.gz",
               bin_sample=config['binning_samples']),
        expand(anvio_dir + "{bin_sample}/{bin_sample}.db.anvi_add_maxbin.done",
               bin_sample=config['binning_samples'])
