# Snakemake pipeline for shotgun data QC

A Snakemake workflow for assessing the quality of many shotgun sequence samples
simultaneously using [Snakemake](https://bitbucket.org/snakemake/snakemake/wiki/Home)
and [MultiQC](http://multiqc.info).

It modifies some code from jlanga's snakemake skeleton
[workflow](https://github.com/jlanga/smsk), and builds on previous code I wrote in [snakemake_shotqual](https://github.com/tanaes/snakemake_shotqual). 


### Installation

Currently, this tool inherits most of its dependencies from a single Conda environment that must be loaded to execute the `launch.sh` script. 

To create this environment, you can run the `install.sh` script in `./bin/install`:

`bash ./bin/install/install.sh`

This will create a conda environment named `snakemake_assemble` with a number of dependencies, including the following tools:

  - [snakemake](https://snakemake.readthedocs.io/en/stable/)
  - [fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
  - [multiqc](http://multiqc.info)
  - [skewer](https://sourceforge.net/projects/skewer/)
  - [bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml)
  - [bedtools](http://bedtools.readthedocs.io/en/latest/)
  - [samtools](https://samtools.github.io)
  - [cramtools](https://github.com/enasequence/cramtools)
  - [megahit](https://github.com/voutcn/megahit)
  - [spades](http://bioinf.spbau.ru/spades)
  - [maxbin2](https://downloads.jbei.org/data/microbial_communities/MaxBin/MaxBin.html)
  - [bbmap](http://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbmap-guide/)

In addition, it will download [Quast](http://quast.bioinf.spbau.ru) and install in the `snakemake_assemble` environment using pip. 

Note that I've had some troubles with the conda recipes for some of these packages, especially MaxBin2. There seem to be some issues with the particular Perl version specified in one of the MaxBin2 dependencies. Currently, I've been getting around this by manually reinstalling the MaxBin2 module. 

Future versions of this pipeline shoud employ Snakemake's [built-in per-rule package management](https://snakemake.readthedocs.io/en/stable/snakefiles/deployment.html#integrated-package-management) so that the environment creation is more modular.


### Usage

This workflow is meant to be modular and configurable for shotgun analyses.

In its simplest iteration, the complete set of rules can be launched for a dataset by activating the `snakemake_assemble` Conda environment and running the following command:

`bash launch.sh ./`

Behind the scenes of `launch.sh`, this invokes the `snakemake` command with instructions for executing on a Torque cluster environment, and defaults to reading per-job resource specifications from `./cluster.json` and run-specific configuration information from `./config.yaml`. Currently, a small test dataset is included in `./example`, and `config.yaml` is set up run the workflow on this test dataset. 

However, unlike my previous shotgun workflow, this is meant to be a more modular process. Rather than executing the entire workflow all at once, there are a series of 'top level' rules defining particular sub-portions of the workflow. These include:

- **raw**: initial read prep and quality description
- **qc**: read qc, adapter trimming, host read removal
- **assemble**: metagenome assembly
- **map**: read mapping to assemblies for coverage profiling
- **bin**: binning of genomes from metagenomes
- **anvio**: creation [Anvi'o](http://merenlab.org/software/anvio/) binning visualizations (this requires a separate Conda environment)
- **taxonomy**: taxonomic profiling of metagenomes

You can execute any of these top-level rules by specifying them after the launch command. Any required prerequisite rules will automatically be executed. For example:

`bash launch.sh ./ raw` will create links from your raw read files to the new data analysis folder, and run FastQC and MultiQC on the raw data. 

`bash launch.sh ./ qc` will do the above, plus run adapter and quality trimming with Skewer, perform host read filtering, and run FastQC and MultiQC on the QC'd data. 

This series of modules with rules to execute particular portions of a shotgun analysis workflow are located in the `./bin/snakefiles` directory.


### Per-run Configuration

Snakemake reads the information necessary to execute the workflow on a particular dataset from a yaml-format configuration file. Currently this includes information about rule-specific environment specification (this should be superceded by the in-built Snakemake environment handling noted above), parameter settings for specific rules (for example, trimming stringency), samples to use for particular steps (for example, only running assembly on a subset of samples), and filepath specification for samples. 

An example configuration file is provided in `config.yaml`. 

Currently, sample-specific information is passed in the `config.yaml` as a dictionary called `samples`, with each sample being keyed by a unique sample name. One record looks like this:

```
samples:
  sample1:
    filter_db: 
    forward: 
    - example/reads/Bs_L001_R1.fastq.gz
    - example/reads/Bs_L002_R1.fastq.gz
    reverse:
    - example/reads/Bs_L001_R2.fastq.gz
    - example/reads/Bs_L002_R2.fastq.gz
```

Each sample can have multiple forward and reverse read fastqs (for example, if the same sample was run across multiple lanes). These will be concatenated together prior to subsequent steps. 

A sample-specific `filter_db` can also be specified -- this should be a Bowtie2 formatted mapping database filepath base. On Barnacle, you can access a few such reference dbs in my home directory:

```
/home/jgsanders/ref_data/genomes/mouse/mouse
/home/jgsanders/ref_data/genomes/Homo_sapiens_Bowtie2_v0.1/Homo_sapiens
/home/jgsanders/ref_data/genomes/phiX/phix
```

### Usage notes

Snakemake requires that inputs and outputs be specified explicitly to construct
the workflow graph. However, I have found that in practice there are samples
in the sequencing manifest that do not show up in the demultiplexed sequence
files, or do not yield all possible output files in Trimmomatic (for example,
if there are no R1 reads that survive trimming). For this reason, I have been
invoking this workflow with the `--keep-going` flag, which will run subsequent
steps even if not all outputs are successfully generated.

Another parameter I've used successfully is `--restart-times`. Sometimes I've had jobs fail stochastically in the cluster environment, and setting this parameter to 1 (default is 0) will cause these failed jobs to automatically re-queue. 

Finally, note that disk access-intensive steps are set to run on a temporary
directory to allow execution on local scratch space in a cluster environment.
This variable is called `TMP_DIR_ROOT` in the config.yaml, and should be set to
the local scratch directory to enable this behavior. 


### How to run

On Barnacle, we want to avoid running compute-intensive jobs on the login node.
That's what happens if we just run the included Snakefile without any
additional information about how to access the cluster.

local execution (**DON'T DO THIS**):
```bash
snakemake --configfile config_Run1.yaml
```

Instead, I've provided a launch.sh script that is set up with some defaults
chosen to improve execution on our cluster. Here's how you run it:

cluster execution (**DO THIS**):
```bash
bash launch.sh ./ --configfile config_Run1.yaml
```

Here's what's goingon behind the scenes in launch.sh to invoke the Snakemake
workflow:

```bash
snakemake -j 16 \
--local-cores 4 \
-w 90 \
--max-jobs-per-second 8 \
--cluster-config cluster.json \
--cluster "qsub -k eo -m n -l nodes=1:ppn={cluster.n} -l mem={cluster.mem}gb -l walltime={cluster.time}" \
--directory "$@"
```

Let's go through what each of these parameters does.

`-j 16`: Runs no more than 16 jobs concurrently. If you have 96 samples that
each need to get FastQC'd, it will only run 16 of these jobs at a time.

`--local-cores 4`: For rules specified as local rules (like linking files),
limits to use of 4 CPUs at a time. 

`-w 90`: Waits for at most 90 seconds after a job executes for the output files
to be available. This has to do with tolerating latency on the filesystem:
sometimes a file is created by a job but isn't immediately visible to the
Snakemake process that's scheduling things.

`--max-jobs-per-second 8`: Limits the rate at which Snakemake is sending jobs
to the cluster.

`--cluster-config cluster.json` Looks in the current directory for a file
called cluster.json that contains information about how many resources to
request from the cluster for each rule type.

`--cluster "qsub -k eo [...]"`: This tells Snakemake how to send a job to the
cluster scheduler, and how to request the specific resources defined in the
cluster.json file.

`--directory "$@"`: This passes all the input provided after `bash launch.sh`
as further input to Snakemake. Because it comes right after the `--directory`
flag, it's going to expect the first element of that input to be the path to
the working directory where Snakemake should execute. 

