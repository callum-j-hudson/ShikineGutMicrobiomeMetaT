#!/bin/bash
#SBATCH -p compute
#SBATCH -t 4-00:00:00
#SBATCH -c 32
#SBATCH --mem=300G
#SBATCH --job-name=cdhit_master_txome
#SBATCH --output=cdhit_master_%j.out
#SBATCH --error=cdhit_master_%j.err
#SBATCH --mail-user=callum.hudson@oist.jp
#SBATCH --mail-type=END,FAIL

set -euo pipefail

# ==========================
# Modules
# ==========================

ml purge
ml cd-hit/2016-0304

# ==========================
# Paths
# ==========================

INPUT_DIR=/flash/RavasiU/Callum/GutMetatranscriptome/rnaSPADES_final
OUT_DIR=/flash/RavasiU/Callum/GutMetatranscriptome/SPADES_assembly_collapsed

mkdir -p "${OUT_DIR}"

# ==========================
# Merge assemblies
# ==========================

MERGED="${OUT_DIR}/all_transcripts.fasta"

echo "Merging transcriptomes..."
cat "${INPUT_DIR}"/*.fasta > "${MERGED}"

echo "Merged transcriptome created:"
ls -lh "${MERGED}"

# ==========================
# CD-HIT-EST clustering
# ==========================

echo "Starting CD-HIT-EST..."

cd-hit-est \
    -i "${MERGED}" \
    -o "${OUT_DIR}/master_95.fasta" \
    -c 0.95 \
    -n 10 \
    -T 32 \
    -M 0

echo "CD-HIT-EST complete"

# ==========================
# Summary
# ==========================

echo ""
echo "Input transcripts:"
grep -c "^>" "${MERGED}"

echo ""
echo "Representative transcripts after clustering:"
grep -c "^>" "${OUT_DIR}/master_95.fasta"

echo ""
echo "Output files:"
ls -lh "${OUT_DIR}/master_95.fasta"*

echo "DONE"