# =========================================================
# 02_Tax_Assign.R
# Taxonomic assignment and phylogenetic tree construction
# =========================================================


# =========================================================
# Load packages
# =========================================================

library(dada2)
library(DECIPHER)
library(Biostrings)
library(phangorn)


# =========================================================
# Set paths
# =========================================================

project_dir <- "/flash/RavasiU/Callum/Microbiome_shikine"

input_file <- file.path(
  project_dir,
  "Results/04_seqtab.nochim.rds"
)

output_dir <- file.path(
  project_dir,
  "Results/02_Temp_Data"
)

tax_output <- file.path(
  output_dir,
  "taxa.rds"
)

fitGTR_output <- file.path(
  output_dir,
  "fitGTR5.rds"
)

tree_output <- file.path(
  output_dir,
  "tree.nwk"
)


# =========================================================
# SILVA 138.2 reference files
# =========================================================

tax_train <- paste0(
  "/bucket/RavasiU/research_data/DADA2_SILVA_138.2/",
  "silva_nr99_v138.2_toGenus_trainset.fa.gz"
)

tax_species <- paste0(
  "/bucket/RavasiU/research_data/DADA2_SILVA_138.2/",
  "silva_v138.2_assignSpecies.fa.gz"
)


# =========================================================
# Check files and directories
# =========================================================

if (!file.exists(input_file)) {
  stop("Input sequence table not found: ", input_file)
}

if (!file.exists(tax_train)) {
  stop("SILVA genus training set not found: ", tax_train)
}

if (!file.exists(tax_species)) {
  stop("SILVA species reference not found: ", tax_species)
}

if (!dir.exists(output_dir)) {
  dir.create(
    output_dir,
    recursive = TRUE,
    showWarnings = FALSE
  )
}


# =========================================================
# Load sequence table
# =========================================================

cat("\n")
cat("========================================\n")
cat("Loading sequence table\n")
cat("========================================\n")

seqtab.nochim <- readRDS(input_file)

cat(
  "Number of samples:",
  nrow(seqtab.nochim),
  "\n"
)

cat(
  "Number of ASVs:",
  ncol(seqtab.nochim),
  "\n"
)


# =========================================================
# Taxonomic assignment
# =========================================================

cat("\n")
cat("========================================\n")
cat("Assigning taxonomy using SILVA 138.2\n")
cat("========================================\n")

taxa <- assignTaxonomy(
  seqtab.nochim,
  tax_train,
  multithread = TRUE
)

cat("Genus-level taxonomic assignment complete.\n")


# =========================================================
# Species assignment
# =========================================================

cat("\n")
cat("========================================\n")
cat("Assigning species using SILVA 138.2\n")
cat("========================================\n")

taxa <- addSpecies(
  taxa,
  tax_species,
  allowMultiple = TRUE
)

cat("Species-level assignment complete.\n")


# =========================================================
# Save taxonomy table
# =========================================================

saveRDS(
  taxa,
  tax_output
)

cat("\nTaxonomy table saved to:\n")
cat(tax_output, "\n")


# =========================================================
# Select samples for phylogenetic tree
# =========================================================

cat("\n")
cat("========================================\n")
cat("Selecting samples for phylogenetic tree\n")
cat("========================================\n")


# Identify samples to remove
samples_to_remove <- grepl(
  "^(Maeganeku_|SeaFarm_|Filter_|Extraction_|Shimoda_|Bacterial_|Undetermined_|Shikine_Blank_)",
  rownames(seqtab.nochim)
)


cat(
  "Samples removed from tree:",
  sum(samples_to_remove),
  "\n"
)


# Subset sequence table
seqtab.tree <- seqtab.nochim[
  !samples_to_remove,
  ,
  drop = FALSE
]


cat(
  "Samples retained for tree:",
  nrow(seqtab.tree),
  "\n"
)


# Remove ASVs absent from all retained samples
seqtab.tree <- seqtab.tree[
  ,
  colSums(seqtab.tree) > 0,
  drop = FALSE
]


cat(
  "ASVs retained for tree:",
  ncol(seqtab.tree),
  "\n"
)


# =========================================================
# Construct phylogenetic tree
# =========================================================

cat("\n")
cat("========================================\n")
cat("Constructing phylogenetic tree\n")
cat("========================================\n")


# ---------------------------------------------------------
# Extract ASV sequences
# ---------------------------------------------------------

seqs <- getSequences(seqtab.tree)

names(seqs) <- seqs

cat(
  "Number of ASV sequences:",
  length(seqs),
  "\n"
)


# ---------------------------------------------------------
# Multiple sequence alignment using DECIPHER
# ---------------------------------------------------------

cat("Performing multiple sequence alignment...\n")

alignment <- AlignSeqs(
  DNAStringSet(seqs),
  anchor = NA,
  verbose = FALSE
)

cat("Multiple sequence alignment complete.\n")


# ---------------------------------------------------------
# Convert alignment to phangorn format
# ---------------------------------------------------------

phangAlign <- phyDat(
  as(alignment, "matrix"),
  type = "DNA"
)

cat("Alignment converted to phangorn format.\n")


# =========================================================
# Build NJ starting tree and optimise GTR+G+I model
# =========================================================

cat("\n")
cat("========================================\n")
cat("Optimising GTR+G+I phylogenetic tree\n")
cat("========================================\n")


# ---------------------------------------------------------
# Calculate ML distances
# ---------------------------------------------------------

cat("Calculating ML distance matrix...\n")

dm <- dist.ml(phangAlign)

cat("ML distance matrix calculated.\n")


# ---------------------------------------------------------
# Build neighbour-joining starting tree
# ---------------------------------------------------------

cat("Constructing neighbour-joining starting tree...\n")

nj_tree <- NJ(dm)

cat("NJ starting tree constructed.\n")


# ---------------------------------------------------------
# Create likelihood object
# ---------------------------------------------------------

fit <- pml(
  nj_tree,
  data = phangAlign
)

cat("Likelihood model initialised.\n")


# ---------------------------------------------------------
# Set initial gamma categories and invariant-site proportion
# ---------------------------------------------------------

fitGTR <- update(
  fit,
  k = 4,
  inv = 0.2
)


# ---------------------------------------------------------
# Optimise GTR + Gamma + invariant-sites model
# ---------------------------------------------------------

cat("Optimising GTR+G+I model using NNI...\n")

fitGTR <- optim.pml(
  fitGTR,
  model = "GTR",
  optInv = TRUE,
  optGamma = TRUE,
  rearrangement = "NNI",
  control = pml.control(trace = 0)
)

cat("GTR+G+I optimisation complete.\n")


# =========================================================
# Save fitted phylogenetic model
# =========================================================

cat("\n")
cat("Saving fitted GTR model...\n")

saveRDS(
  fitGTR,
  fitGTR_output
)

cat("Fitted model saved to:\n")
cat(fitGTR_output, "\n")


# =========================================================
# Extract and save phylogenetic tree
# =========================================================

cat("\n")
cat("Saving phylogenetic tree...\n")

tree <- fitGTR$tree

ape::write.tree(
  tree,
  file = tree_output
)

cat("Phylogenetic tree saved to:\n")
cat(tree_output, "\n")


# =========================================================
# Summary
# =========================================================

cat("\n")
cat("========================================\n")
cat("FINAL SUMMARY\n")
cat("========================================\n")

cat(
  "Total samples in sequence table:",
  nrow(seqtab.nochim),
  "\n"
)

cat(
  "Samples removed from tree:",
  sum(samples_to_remove),
  "\n"
)

cat(
  "Samples used for tree:",
  nrow(seqtab.tree),
  "\n"
)

cat(
  "Total ASVs in sequence table:",
  ncol(seqtab.nochim),
  "\n"
)

cat(
  "ASVs used for tree:",
  ncol(seqtab.tree),
  "\n"
)


# =========================================================
# Taxonomic assignment summary
# =========================================================

cat("\n")
cat("Taxonomic assignments:\n")

cat(
  "Kingdom:",
  sum(!is.na(taxa[, "Kingdom"])),
  "\n"
)

cat(
  "Phylum:",
  sum(!is.na(taxa[, "Phylum"])),
  "\n"
)

cat(
  "Class:",
  sum(!is.na(taxa[, "Class"])),
  "\n"
)

cat(
  "Order:",
  sum(!is.na(taxa[, "Order"])),
  "\n"
)

cat(
  "Family:",
  sum(!is.na(taxa[, "Family"])),
  "\n"
)

cat(
  "Genus:",
  sum(!is.na(taxa[, "Genus"])),
  "\n"
)

cat(
  "Species:",
  sum(!is.na(taxa[, "Species"])),
  "\n"
)


# =========================================================
# Output files
# =========================================================

cat("\n")
cat("Output files:\n")

cat(tax_output, "\n")
cat(fitGTR_output, "\n")
cat(tree_output, "\n")

cat("\n")
cat("Taxonomic assignment and phylogenetic tree construction complete.\n")
