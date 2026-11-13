#!/bin/bash
#SBATCH -p compute
#SBATCH -t 1-00:00:00
#SBATCH -c 12
#SBATCH --mem=60G
#SBATCH --array=0-30%6
#SBATCH --job-name=salmon_all
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=callum.hudson@oist.jp
#SBATCH --output=salmon_%A_%a.out
#SBATCH --error=salmon_%A_%a.err

ml salmon/1.3.0

# -----------------------------
# Paths
# -----------------------------
FASTA=/flash/RavasiU/Callum/GutMetatranscriptome/SPADES_assembly_collapsed/master_95.fasta
INDEX=/flash/RavasiU/Callum/GutMetatranscriptome/TranscriptomeIndexSalmon
INDIR=/bucket/RavasiU/Callum/GutMetatranscriptome/04_sortmerna
OUTDIR=/flash/RavasiU/Callum/GutMetatranscriptome/05_tx_mapping_salmon

mkdir -p $OUTDIR
mkdir -p $INDEX

# -----------------------------
# Build index ONLY once (race-safe)
# -----------------------------
LOCKDIR=$INDEX/.lock

if [ ! -f "$INDEX/complete" ]; then

    if mkdir "$LOCKDIR" 2>/dev/null; then
        echo "Building Salmon index..."

        salmon index \
          -t $FASTA \
          -i $INDEX \
          -p 12

        touch "$INDEX/complete"
        rmdir "$LOCKDIR"

        echo "Index build complete."

    else
        echo "Index is being built by another job. Waiting..."
        while [ ! -f "$INDEX/complete" ]; do
            sleep 30
        done
        echo "Index ready."
    fi

else
    echo "Index already exists. Skipping build."
fi

# -----------------------------
# Sample selection
# -----------------------------
SAMPLES=($(find $INDIR -maxdepth 1 -type d -name "S*" | sort))
SAMPLE_DIR=${SAMPLES[$SLURM_ARRAY_TASK_ID]}
sample=$(basename $SAMPLE_DIR)

R1=$SAMPLE_DIR/non_rRNA_fwd.fq.gz
R2=$SAMPLE_DIR/non_rRNA_rev.fq.gz

echo "Quantifying $sample"

# -----------------------------
# Salmon quant
# -----------------------------
salmon quant \
  -i $INDEX \
  -l A \
  -1 $R1 \
  -2 $R2 \
  -p 12 \
  --validateMappings \
  -o $OUTDIR/${sample}_salmon

echo "Done $sample"