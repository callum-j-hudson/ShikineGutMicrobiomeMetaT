#!/bin/bash
#SBATCH -p compute
#SBATCH -t 4-00:00:00
#SBATCH -c 20
#SBATCH --mem=200G
#SBATCH --job-name=eggnog_master

set -eo pipefail

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate eggnog

PEP=/flash/RavasiU/Callum/GutMetatranscriptome/06_prodigal/master_95.pep
OUTDIR=/flash/RavasiU/Callum/GutMetatranscriptome/07_eggnog
DBDIR=/bucket/RavasiU/research_data/eggnog_db

mkdir -p $OUTDIR

emapper.py \
  -i $PEP \
  --itype proteins \
  --cpu 20 \
  --data_dir $DBDIR \
  --output master_eggnog \
  --output_dir $OUTDIR