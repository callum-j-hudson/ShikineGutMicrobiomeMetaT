#!/bin/bash
#SBATCH -p compute
#SBATCH -t 2-0
#SBATCH -c 20
#SBATCH --mem=200G
#SBATCH --job-name=eggnog_Spez
#SBATCH --output=eggnog_Spez_%j.out
#SBATCH --error=eggnog_Spez_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=callum.hudson@oist.jp

set -eo pipefail

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate eggnog

PEP=/flash/RavasiU/Callum/UrchinPhylogeny/SpeciesTreeInput/Spez.pep
OUTDIR=/flash/RavasiU/Callum/GutMetatranscriptome/eggnog_annotation_Spez
DBDIR=/bucket/RavasiU/research_data/eggnog_db

mkdir -p "$OUTDIR"

echo "Protein count:"
grep -c "^>" "$PEP"

emapper.py \
  -i "$PEP" \
  --itype proteins \
  --cpu 20 \
  --data_dir "$DBDIR" \
  --output Spez_eggnog \
  --output_dir "$OUTDIR"

echo "Done"