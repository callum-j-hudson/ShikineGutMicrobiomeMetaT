#!/bin/bash
#SBATCH -p compute
#SBATCH -t 4-00:00:00
#SBATCH -c 20
#SBATCH --mem=200G
#SBATCH --job-name=picrust2_
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=callum.hudson@oist.jp
#SBATCH --output=Picrust2_%j.out
#SBATCH --error=Picrust2_%j.err

ml purge
ml bioinfo-ugrp-modules
ml singularity

# ----------------------------
# INPUT FILES
# ----------------------------

INPUT_DIR=/bucket/RavasiU/Callum/Microbiome/Shikine/PICRUST

SEQS=$INPUT_DIR/rep_seqs.fasta
TABLE=$INPUT_DIR/feature_table.tsv

# ----------------------------
# OUTPUT DIRECTORY (UNIQUE PER JOB = SAFE)
# ----------------------------

OUTDIR=/flash/RavasiU/Callum/Microbiome_shikine/PICRUST/picrust2_out_${SLURM_JOB_ID}

echo "Output directory: $OUTDIR"

# ----------------------------
# CONTAINER
# ----------------------------

SIF=/apps/unit/RavasiU/picrust2/picrust2.sif

# ----------------------------
# RUN PICRUST2
# ----------------------------

echo "Starting PICRUSt2 pipeline..."

singularity exec \
    -B /bucket:/bucket \
    -B /flash:/flash \
    -B /apps:/apps \
    "$SIF" \
    picrust2_pipeline.py \
    -s "$SEQS" \
    -i "$TABLE" \
    -o "$OUTDIR" \
    -p "${SLURM_CPUS_PER_TASK:-20}"

echo "PICRUSt2 finished"
echo "Output written to: $OUTDIR"