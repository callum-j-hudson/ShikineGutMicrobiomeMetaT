#!/bin/bash
#SBATCH -p compute
#SBATCH -t 4-00:00:00
#SBATCH -c 12
#SBATCH --mem=300G
#SBATCH --job-name=rnaspades_array
#SBATCH --array=0-30%5
#SBATCH --output=logs/rnaspades_%A_%a.out
#SBATCH --error=logs/rnaspades_%A_%a.err
#SBATCH --mail-user=callum.hudson@oist.jp
#SBATCH --mail-type=END,FAIL

set -euo pipefail

# ==========================
# Modules
# ==========================
ml purge
ml python/3.10.2
ml SPAdes_latest

# ==========================
# Paths
# ==========================
READ_DIR=/bucket/RavasiU/Callum/GutMetatranscriptome/Microbes_sortmerna
FINAL_OUT=/flash/RavasiU/Callum/GutMetatranscriptome/rnaSPADES_final

mkdir -p logs
mkdir -p "$FINAL_OUT"

# ==========================
# Build sample list SAFELY
# ==========================
mapfile -t SAMPLES < <(ls ${READ_DIR}/*_1.non_rRNA.fastq.gz | sort)

# safety check
if [[ ${#SAMPLES[@]} -eq 0 ]]; then
    echo "ERROR: No input FASTQ files found"
    exit 1
fi

if [[ $SLURM_ARRAY_TASK_ID -ge ${#SAMPLES[@]} ]]; then
    echo "ERROR: Array index out of range"
    exit 1
fi

# ==========================
# Get sample pair
# ==========================
R1=${SAMPLES[$SLURM_ARRAY_TASK_ID]}
R2=${R1/_1.non_rRNA.fastq.gz/_2.non_rRNA.fastq.gz}

SAMPLE=$(basename "$R1" _1.non_rRNA.fastq.gz)

echo "=============================="
echo "Sample: $SAMPLE"
echo "=============================="

# ==========================
# Working directory (local on node OR shared flash-safe staging)
# ==========================
WORKDIR=/flash/RavasiU/Callum/scratch_rnaspades/${SLURM_JOB_ID}/${SAMPLE}
mkdir -p "$WORKDIR"

# ==========================
# Run rnaSPAdes
# ==========================
rnaspades.py \
  -1 "$R1" \
  -2 "$R2" \
  -o "$WORKDIR" \
  --threads 12 \
  --memory 300

# ==========================
# KEEP ONLY FINAL TRANSCRIPTS
# ==========================
if [[ -f "$WORKDIR/transcripts.fasta" ]]; then
    cp "$WORKDIR/transcripts.fasta" \
       "$FINAL_OUT/${SAMPLE}_transcripts.fasta"
else
    echo "ERROR: transcripts.fasta missing for $SAMPLE"
    exit 1
fi

# ==========================
# CLEAN EVERYTHING ELSE
# ==========================
rm -rf "$WORKDIR"

echo "DONE: $SAMPLE"
