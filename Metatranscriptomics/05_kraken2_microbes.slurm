#!/bin/bash
#SBATCH -p compute
#SBATCH -t 4-00:00:00
#SBATCH -c 16
#SBATCH --mem=180G
#SBATCH --job-name=kraken2_bacteria
#SBATCH --output=kraken2_%A_%a.out
#SBATCH --error=kraken2_%A_%a.err
#SBATCH --mail-user=callum.hudson@oist.jp
#SBATCH --mail-type=END,FAIL
#SBATCH --array=0-30%12

set -euo pipefail

# ==========================================================
# Load Kraken2
# ==========================================================

module purge
module load kraken2

# ==========================================================
# Paths
# ==========================================================

DIRin=/bucket/RavasiU/Callum/GutMetatranscriptome/03_NoHostReads

DIRout=/flash/RavasiU/Callum/GutMetatranscriptome/kraken_results_bacteria

DB=/bucket/RavasiU/research_data/kraken2_bacterial_archaeal/4.08.20

mkdir -p "${DIRout}"

# ==========================================================
# Sample list
# ==========================================================

mapfile -t FILES < <(ls "${DIRin}"/S*_R1.fastq.gz | sort)

R1=${FILES[$SLURM_ARRAY_TASK_ID]}
R2=${R1/_R1.fastq.gz/_R2.fastq.gz}

NAME=$(basename "${R1}" _R1.fastq.gz)

echo "======================================"
echo "Processing sample: ${NAME}"
echo "Database: ${DB}"
echo "======================================"

# ==========================================================
# Skip completed samples
# ==========================================================

if [[ -f "${DIRout}/${NAME}.report" ]]; then
    echo "Sample already completed. Skipping."
    exit 0
fi

# ==========================================================
# Kraken2 classification
# ==========================================================

kraken2 \
    --db "${DB}" \
    --paired \
    --threads 16 \
    --confidence 0.3 \
    --memory-mapping \
    --gzip-compressed \
    --use-names \
    --report-zero-counts \
    --report "${DIRout}/${NAME}.report" \
    --output "${DIRout}/${NAME}.kraken" \
    "${R1}" "${R2}"

echo "Finished ${NAME}"