# create conda env
conda env create -y -f bin/install/requirements.yaml

source activate conda

# download and install quast

wget https://downloads.sourceforge.net/project/quast/quast-4.4.tar.gz
tar -xzf quast-4.4.tar.gz
cd quast-4.4
pip install -e .