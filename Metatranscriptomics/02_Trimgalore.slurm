#!/bin/bash
#SBATCH -p compute
#SBATCH -t 0-24
#SBATCH -c 4
#SBATCH --mem=40G
#SBATCH --array=0-30%20
#SBATCH --mail-user=callum.hudson@oist.jp
#SBATCH --mail-type=END,FAIL

ml fastqc/0.11.9
ml cutadapt
ml trimgalore

DIRin=/bucket/RavasiU/Callum/GutMetatranscriptome/00_RawData
DIRout=/flash/RavasiU/Callum/GutMetatranscriptome/02_TrimmedReads

mkdir -p ${DIRout}

files=(${DIRin}/*_R1_001.fastq.gz)

R1_file=${files[$SLURM_ARRAY_TASK_ID-1]}
name=$(basename ${R1_file} _R1_001.fastq.gz)
R2_file=${R1_file/_R1_001/_R2_001}

echo "Processing sample: $name"

trim_galore \
  --paired \
  --retain_unpaired \
  --quality 5 \
  --length 30 \
  --fastqc \
  --cores 4 \
  --output_dir ${DIRout} \
  ${R1_file} ${R2_file}

