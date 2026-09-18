#!/bin/bash
#SBATCH -p compute
#SBATCH -t 2-0
#SBATCH -c 20
#SBATCH --mem=500G
#SBATCH --job-name=nfcore_gut_host
#SBATCH --output=nfcore_gut_host_%j.out
#SBATCH --error=nfcore_gut_host_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=callum.hudson@oist.jp

ml bioinfo-ugrp-modules nf-core

# ----------------------------
# Paths (ALL on fast storage)
# ----------------------------
export NXF_WORK=/flash/RavasiU/Callum/GutMetatranscriptome/nf_core/Host/nfcore_work
export SINGULARITY_CACHEDIR=/flash/RavasiU/Callum/GutMetatranscriptome/nf_core/Host/singularity_cache
export SINGULARITY_TMPDIR=/flash/RavasiU/Callum/GutMetatranscriptome/nf_core/Host/singularity_tmp
export NXF_SINGULARITY_CACHEDIR=$SINGULARITY_CACHEDIR

mkdir -p $NXF_WORK $SINGULARITY_CACHEDIR $SINGULARITY_TMPDIR

# ----------------------------
# Inputs
# ----------------------------
OUTDIR=/flash/RavasiU/Callum/GutMetatranscriptome/nf_core/Host/nfcore_out
SAMPLESHEET=/flash/RavasiU/Callum/GutMetatranscriptome/nf_core_host_samplesheet.csv
GENOME=/bucket/RavasiU/Callum/GutMetatranscriptome/spez_chrom_genome_final.fasta
GTF=/bucket/RavasiU/Callum/GutMetatranscriptome/spez_annotations.gtf

# ----------------------------
# Run nf-core/rnaseq
# ----------------------------
nextflow run nf-core/rnaseq \
  --input ${SAMPLESHEET} \
  --outdir ${OUTDIR} \
  --gtf ${GTF} \
  --fasta ${GENOME} \
  --remove_ribo_rna \
  --aligner star_salmon \
  -profile oist \
  -resume