# =========================================================
# 01_DADA2
# DADA2 pipeline for Shikine microbiome data
# =========================================================

# Load packages
library(dada2)
library(tidyverse)

# =========================================================
# Set number of threads from Slurm
# =========================================================

threads <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))

cat("Using", threads, "CPU threads\n")

# =========================================================
# Input FASTQ files
# =========================================================

path <- "/bucket/RavasiU/Callum/Microbiome/Shikine/RawData/fastq"

fnFs <- sort(
  list.files(
    path,
    pattern = "_R1_001.fastq.gz$",
    full.names = TRUE
  )
)

fnRs <- sort(
  list.files(
    path,
    pattern = "_R2_001.fastq.gz$",
    full.names = TRUE
  )
)

# Check that forward and reverse files match
cat("Number of forward files:", length(fnFs), "\n")
cat("Number of reverse files:", length(fnRs), "\n")

if (length(fnFs) != length(fnRs)) {
  stop("Number of R1 and R2 files does not match.")
}

# =========================================================
# Extract sample names
# =========================================================

sample.names <- sapply(
  strsplit(basename(fnFs), "_R1_001"),
  `[`,
  1
)

print(sample.names)

# =========================================================
# Set output directory
# =========================================================

results <- "/flash/RavasiU/Callum/Microbiome_shikine/Results"

dir.create(
  results,
  recursive = TRUE,
  showWarnings = FALSE
)

# =========================================================
# Read quality
# =========================================================

pdf(
  file.path(results, "01_Quality_Profiles.pdf")
)

plotQualityProfile(
  fnFs[1:min(2, length(fnFs))]
)

plotQualityProfile(
  fnRs[1:min(2, length(fnRs))]
)

dev.off()

# =========================================================
# Filtered read output
# =========================================================

pathfilt <- file.path(
  results,
  "01_Filtered_Data"
)

dir.create(
  file.path(pathfilt, "filtered"),
  recursive = TRUE,
  showWarnings = FALSE
)

filtFs <- file.path(
  pathfilt,
  "filtered",
  paste0(sample.names, "_F_filt.fastq.gz")
)

filtRs <- file.path(
  pathfilt,
  "filtered",
  paste0(sample.names, "_R_filt.fastq.gz")
)

# =========================================================
# Filter and trim
# =========================================================

out <- filterAndTrim(
  fnFs,
  filtFs,
  fnRs,
  filtRs,
  truncLen = c(300,300),
  trimLeft = c(22, 26),
  maxN = 0,
  maxEE = c(3, 4),
  truncQ = 2,
  rm.phix = TRUE,
  compress = TRUE,
  multithread = threads
)

write.csv(
  out,
  file.path(results, "01_FilterAndTrim_summary.csv"),
  row.names = TRUE
)

# =========================================================
# Learn error rates
# =========================================================

errF <- learnErrors(
  filtFs,
  multithread = threads
)

errR <- learnErrors(
  filtRs,
  multithread = threads
)

# Plot error rates
pdf(
  file.path(results, "02_Error_Rates.pdf")
)

plotErrors(
  errF,
  nominalQ = TRUE
)

plotErrors(
  errR,
  nominalQ = TRUE
)

dev.off()

# =========================================================
# Dereplication
# =========================================================

derepFs <- derepFastq(
  filtFs,
  verbose = TRUE
)

derepRs <- derepFastq(
  filtRs,
  verbose = TRUE
)

names(derepFs) <- sample.names
names(derepRs) <- sample.names

# =========================================================
# Sequence inference
# =========================================================

dadaFs <- dada(
  derepFs,
  err = errF,
  multithread = threads
)

dadaRs <- dada(
  derepRs,
  err = errR,
  multithread = threads
)

# =========================================================
# Merge paired reads
# =========================================================

mergers <- mergePairs(
  dadaFs,
  derepFs,
  dadaRs,
  derepRs,
  verbose = TRUE
)

# =========================================================
# Construct ASV table
# =========================================================

seqtab <- makeSequenceTable(mergers)

cat(
  "ASV table dimensions:",
  dim(seqtab)[1],
  "samples x",
  dim(seqtab)[2],
  "ASVs\n"
)

print(
  table(nchar(getSequences(seqtab)))
)

# =========================================================
# Remove chimeras
# =========================================================

seqtab.nochim <- removeBimeraDenovo(
  seqtab,
  method = "consensus",
  multithread = threads,
  verbose = TRUE
)

# =========================================================
# Track reads through pipeline
# =========================================================

getN <- function(x) sum(getUniques(x))

track <- cbind(
  out,
  sapply(dadaFs, getN),
  sapply(dadaRs, getN),
  sapply(mergers, getN),
  rowSums(seqtab.nochim),
  round(
    rowSums(seqtab.nochim) /
      as.data.frame(out)$reads.in * 100,
    digits = 1
  )
)

colnames(track) <- c(
  "input",
  "filtered",
  "denoisedF",
  "denoisedR",
  "merged",
  "nonchim",
  "percentage"
)

rownames(track) <- sample.names

print(track)

write.csv(
  track,
  file.path(results, "03_DADA2_read_tracking.csv"),
  row.names = TRUE
)

# =========================================================
# Save DADA2 results
# =========================================================

saveRDS(
  seqtab.nochim,
  file.path(results, "04_seqtab.nochim.rds")
)

saveRDS(
  seqtab,
  file.path(results, "04_seqtab.rds")
)

saveRDS(
  errF,
  file.path(results, "05_errF.rds")
)

saveRDS(
  errR,
  file.path(results, "05_errR.rds")
)

cat("\nDADA2 pipeline completed successfully.\n")
