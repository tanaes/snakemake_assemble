conda config --add channels conda-forge
conda config --add channels defaults
conda config --add channels r
conda config --add channels bioconda
conda config --add channels anaconda
conda env create --name snakemake_assemble --file bin/install/requirements.txt
