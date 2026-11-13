#!/bin/bash
#SBATCH -p compute
#SBATCH -t 0-24
#SBATCH -c 8
#SBATCH --mem=40G
#SBATCH --array=1-31%15
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=callum.hudson@oist.jp

ml bowtie2/2.4.2

TRIM=/flash/RavasiU/Callum/GutMetatranscriptome/02_TrimmedReads
INDEX=/flash/RavasiU/Callum/GutMetatranscriptome/HostGenomeIndex/Echinometra_host

MICROBE=/flash/RavasiU/Callum/GutMetatranscriptome/03_NoHostReads
HOST=/flash/RavasiU/Callum/GutMetatranscriptome/03_HostReads

mkdir -p ${MICROBE}
mkdir -p ${HOST}

files=(${TRIM}/*_R1_001_val_1.fq.gz)

R1=${files[$SLURM_ARRAY_TASK_ID-1]}
sample=$(basename ${R1} _R1_001_val_1.fq.gz)
R2=${TRIM}/${sample}_R2_001_val_2.fq.gz

echo "Separating host + microbial reads: $sample"

bowtie2 \
  -x ${INDEX} \
  -1 ${R1} \
  -2 ${R2} \
  -p 8 \
  --very-sensitive \
  --un-conc-gz ${MICROBE}/${sample}_microbial.fastq.gz \
  --al-conc-gz ${HOST}/${sample}_host.fastq.gz \
  -S /dev/null
