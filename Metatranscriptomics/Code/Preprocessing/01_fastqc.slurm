#!/bin/bash
#SBATCH -p compute
#SBATCH -t 0-12
#SBATCH -c 20
#SBATCH --mem=50G
#SBATCH --mail-user=callum.hudson@oist.jp
#SBATCH --mail-type=END,FAIL

module load fastqc/0.11.9

DIRin=/bucket/RavasiU/Callum/GutMetatranscriptome/00_RawData
DIRout=/flash/RavasiU/Callum/GutMetatranscriptome/Raw_fastqc

mkdir -p ${DIRout}

fastqc -t 20 -q -o "${DIRout}" "${DIRin}"/*.gz


