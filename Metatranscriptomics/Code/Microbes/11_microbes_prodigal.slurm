#!/bin/bash
#SBATCH -p compute
#SBATCH -t 4-00:00:00
#SBATCH -c 20
#SBATCH --mem=200G
#SBATCH --job-name=prodigal_master
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=callum.hudson@oist.jp
#SBATCH --output=Prodigal_%j.out
#SBATCH --error=Prodigal_%j.err

ml purge
ml bioinfo-ugrp-modules
ml Prodigal/2.6.2

FASTA=/flash/RavasiU/Callum/GutMetatranscriptome/SPADES_assembly_collapsed/master_95.fasta
OUTDIR=/flash/RavasiU/Callum/GutMetatranscriptome/06_prodigal

mkdir -p $OUTDIR

echo "Running Prodigal..."

prodigal \
    -i $FASTA \
    -a $OUTDIR/master_95.pep \
    -d $OUTDIR/master_95.cds \
    -o $OUTDIR/master_95.gff \
    -f gff \
    -p meta

echo "Done Prodigal"

echo "Protein count:"
grep -c "^>" $OUTDIR/master_95.pep

echo "CDS count:"
grep -c "^>" $OUTDIR/master_95.cds