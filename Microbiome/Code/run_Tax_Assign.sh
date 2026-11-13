#!/bin/bash

#SBATCH -p compute
#SBATCH --job-name=TaxAssign_Shikine
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=48:00:00

#SBATCH --output=/flash/RavasiU/Callum/Microbiome_shikine/Results/TaxAssign_%j.out
#SBATCH --error=/flash/RavasiU/Callum/Microbiome_shikine/Results/TaxAssign_%j.err


# =========================================================
# Load R
# =========================================================

module load R/4.3.1

export R_LIBS_USER=/home/c/callum-hudson/R/library/4.3

# ICU library needed by igraph
export LD_LIBRARY_PATH=/bucket/BioinfoUgrp/Other__brokenperms/nf-core/2.10/lib:$LD_LIBRARY_PATH

# =========================================================
# Move to project directory
# =========================================================

cd /flash/RavasiU/Callum/Microbiome_shikine


# =========================================================
# Run taxonomic assignment
# =========================================================

Rscript 02_Tax_Assign.R

