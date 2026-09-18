#!/bin/bash
#SBATCH -p compute
#SBATCH -t 0-4
#SBATCH -c 8
#SBATCH --mem=40G
#SBATCH --job-name=build_tx_index

ml bowtie2/2.4.2

TRANSCRIPTOME=/flash/RavasiU/Callum/GutMetatranscriptome/SPADES_assembly_collapsed/master_95.fasta
OUTDIR=/flash/RavasiU/Callum/GutMetatranscriptome/TranscriptomeIndex

mkdir -p $OUTDIR

bowtie2-build \
  --threads 8 \
  $TRANSCRIPTOME \
  $OUTDIR/master_tx