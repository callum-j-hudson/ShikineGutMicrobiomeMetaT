#!/bin/bash
#SBATCH -p compute
#SBATCH -t 04:00:00
#SBATCH -c 10
#SBATCH --mem=40G
#SBATCH --job-name=sortmerna_index
#SBATCH --output=sortmerna_index.out
#SBATCH --error=sortmerna_index.err

set -euo pipefail

module load miniconda
source ~/miniconda3/etc/profile.d/conda.sh

conda activate sortmerna

DB=/bucket/RavasiU/research_data/sortmerna_db/smr_v4.3_sensitive_db.fasta
IDX=/flash/RavasiU/Callum/GutMetatranscriptome/sortmerna_index

mkdir -p $IDX

sortmerna \
  --ref /bucket/RavasiU/research_data/sortmerna_db/smr_v4.3_sensitive_db.fasta \
  --reads empty.fastq \
  --idx-dir /flash/RavasiU/Callum/GutMetatranscriptome/sortmerna_index \
  --task 5 \
  --threads 10
