#!/bin/bash
#SBATCH -p compute
#SBATCH -t 2-0
#SBATCH -c 10
#SBATCH --mem=50G
#SBATCH --job-name=sortmerna
#SBATCH --array=0-30%6
#SBATCH --mail-type=END,FAIL
#SBATCH --output=sortmerna_%A_%a.out
#SBATCH --error=sortmerna_%A_%a.err

set -euo pipefail

module load miniconda
source ~/miniconda3/etc/profile.d/conda.sh

conda activate sortmerna

echo "HOSTNAME: $(hostname)"
echo "THREADS: $SLURM_CPUS_PER_TASK"

which sortmerna
sortmerna --version

DB=/bucket/RavasiU/research_data/sortmerna_db/smr_v4.3_sensitive_db.fasta

IN=/flash/RavasiU/Callum/GutMetatranscriptome/03_NoHostReads
OUT=/flash/RavasiU/Callum/GutMetatranscriptome/04_sortmerna

mkdir -p $OUT

FILES=($IN/*_R1.fastq.gz)

R1=${FILES[$SLURM_ARRAY_TASK_ID]}
R2=${R1/_R1.fastq.gz/_R2.fastq.gz}

sample=$(basename $R1 _R1.fastq.gz)

echo "Processing $sample"
echo "R1=$R1"
echo "R2=$R2"

mkdir -p $OUT/$sample

sortmerna \
  --ref $DB \
  --reads $R1 \
  --reads $R2 \
  --workdir $OUT/$sample \
  --threads $SLURM_CPUS_PER_TASK \
  --fastx \
  --aligned $OUT/$sample/rRNA \
  --other $OUT/$sample/non_rRNA \
  --paired_in \
  --out2 \
  --zip-out
