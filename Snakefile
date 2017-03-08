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
include: snakefiles + "clean"
include: snakefiles + "test"

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
        expand(assemble_dir + "{sample}/metaquast/done.txt",
               sample=samples),
        expand(assemble_dir + "{sample}/quast/done.txt",
               sample=samples),
    # Mapping
        expand(map_dir + "{sample}/mapping/{sample}_{bin_sample}.cram",
               sample=samples, bin_sample=config['binning_samples']),
    # Binning
        expand(bin_dir + "{sample}/abundance_files/{sample}_abund_list.txt",
               sample = samples),
        expand(bin_dir + "{sample}/maxbin/{sample}.summary",
               sample = samples)
