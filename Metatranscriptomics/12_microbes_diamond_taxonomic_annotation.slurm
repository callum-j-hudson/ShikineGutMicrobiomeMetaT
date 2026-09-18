#!/bin/bash
#SBATCH -p compute
#SBATCH -t 4-00:00:00
#SBATCH -c 20
#SBATCH --mem=300G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=callum.hudson@oist.jp
#SBATCH --job-name=diamond_tax
#SBATCH --output=Diamond_%j.out
#SBATCH --error=Diamond_%j.err

ml Other/DIAMOND/2.0.15.153

PEP=/flash/RavasiU/Callum/GutMetatranscriptome/06_prodigal/master_95.pep
OUTDIR=/flash/RavasiU/Callum/GutMetatranscriptome/07_diamond_taxa
DB=/bucket/RavasiU/research_data/gtdb_r220_diamond/gtdb-r220.taxonomy.dmnd

mkdir -p $OUTDIR

diamond blastp \
  -q $PEP \
  -d $DB \
  -o $OUTDIR/master_gtdb.tsv \
  -f 6 qseqid sseqid staxids pident length evalue bitscore \
  -k 1 \
  --sensitive \
  --threads 20