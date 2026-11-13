#!/bin/bash
#SBATCH -p compute
#SBATCH -t 4-00:00:00
#SBATCH -c 20
#SBATCH --mem=200G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=callum.hudson@oist.jp
#SBATCH --job-name=bacterial_eggnog
#SBATCH --output=bacterial_eggnog_%j.out
#SBATCH --error=bacterial_eggnog_%j.err

set -eo pipefail

ml Other/seqkit

############################################
# Paths
############################################

PEP=/flash/RavasiU/Callum/GutMetatranscriptome/06_prodigal/master_95.pep

GTDB=/flash/RavasiU/Callum/GutMetatranscriptome/07_diamond_taxa/master_gtdb.tsv

OUTDIR=/flash/RavasiU/Callum/GutMetatranscriptome/07b_bacterial_eggnog

DBDIR=/bucket/RavasiU/research_data/eggnog_db


mkdir -p $OUTDIR


############################################
# 1. Extract bacterial ORF IDs from GTDB
############################################

echo "Extracting bacterial ORF IDs..."

awk '$7 >= 50 {print $1}' $GTDB | sort -u > $OUTDIR/bacterial_ids.txt


echo "Number of bacterial ORFs:"
wc -l $OUTDIR/bacterial_ids.txt


############################################
# 2. Extract bacterial proteins
############################################

echo "Extracting bacterial proteins..."

seqkit grep \
  -f $OUTDIR/bacterial_ids.txt \
  $PEP \
  > $OUTDIR/bacterial_proteins.pep


echo "Extracted proteins:"
grep -c "^>" $OUTDIR/bacterial_proteins.pep


############################################
# 3. Run eggNOG mapper
############################################

echo "Running eggNOG mapper..."

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate eggnog


emapper.py \
  -i $OUTDIR/bacterial_proteins.pep \
  --itype proteins \
  --cpu 20 \
  --data_dir $DBDIR \
  --output bacterial_eggnog \
  --output_dir $OUTDIR


echo "DONE"