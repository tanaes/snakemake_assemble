import os
import tempfile

shell.prefix("set -euo pipefail;")
configfile: "config.yaml"

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
    input:
        expand(data_dir + "{sample}/{sample}_links.done", sample=samples)
