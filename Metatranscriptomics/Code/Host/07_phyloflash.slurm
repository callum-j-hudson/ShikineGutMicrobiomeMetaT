#!/bin/bash
#SBATCH -p compute
#SBATCH -t 1-0
#SBATCH -c 16
#SBATCH --cpus-per-task=16
#SBATCH --mem=120G
#SBATCH --job-name=phyloflash
#SBATCH --array=0-30%8
#SBATCH --output=phyloflash_%A_%a.out
#SBATCH --error=phyloflash_%A_%a.err

set -euo pipefail

module load Other/phyloflash/3.4.2
module load mafft/7.305

export PATH=$(dirname $(which mafft)):$PATH

INDIR=/bucket/RavasiU/Callum/GutMetatranscriptome/04_sortmerna
DBHOME=/bucket/RavasiU/research_data/138.1

SAMPLE=$(ls -d ${INDIR}/S* | sort | sed -n "$((SLURM_ARRAY_TASK_ID+1))p")
LIBNAME=$(basename "${SAMPLE}")

READ1=${SAMPLE}/rRNA_fwd.fq.gz
READ2=${SAMPLE}/rRNA_rev.fq.gz

OUT=/flash/RavasiU/Callum/GutMetatranscriptome/06_phyloflash

mkdir -p "${OUT}"
cd "${OUT}"

echo "LIBNAME=${LIBNAME}"
echo "SAMPLE=${SAMPLE}"
echo "OUT=${OUT}"

phyloFlash.pl \
    -lib ${LIBNAME} \
    -almosteverything \
    -CPUs ${SLURM_CPUS_PER_TASK} \
    -dbhome ${DBHOME} \
    -read1 ${READ1} \
    -read2 ${READ2} \
    -zip \
    -log

echo "DONE: ${LIBNAME}"