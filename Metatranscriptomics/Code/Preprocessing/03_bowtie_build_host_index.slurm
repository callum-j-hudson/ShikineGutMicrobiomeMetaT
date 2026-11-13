#!/bin/bash
#SBATCH -p compute
#SBATCH -t 0-8
#SBATCH -c 8
#SBATCH --mem=40G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=callum.hudson@oist.jp

ml bowtie2/2.4.2

GENOME=/bucket/RavasiU/Callum/GutMetatranscriptome/spez_chrom_genome_final.fasta
OUTDIR=/flash/RavasiU/Callum/GutMetatranscriptome/HostGenomeIndex

mkdir -p ${OUTDIR}

bowtie2-build \
  --threads 8 \
  ${GENOME} \
  ${OUTDIR}/Echinometra_host
