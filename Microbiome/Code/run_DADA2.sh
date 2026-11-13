#!/bin/bash
#SBATCH -p compute
#SBATCH --job-name=DADA2_Shikine
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=/flash/RavasiU/Callum/Microbiome_shikine/Results/DADA2_%j.out
#SBATCH --error=/flash/RavasiU/Callum/Microbiome_shikine/Results/DADA2_%j.err

module load R/4.3.1

export R_LIBS_USER=/home/c/callum-hudson/R/library/4.3

cd /flash/RavasiU/Callum/Microbiome_shikine

Rscript 01_DADA2.R

# to run script chmod +x run_DADA2.sh
