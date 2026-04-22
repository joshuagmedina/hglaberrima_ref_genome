#!/bin/bash
# STAR two-pass alignment against the soft-masked Hglab v4 genome.
# Run once per RNA-seq dataset: intestine (this study), RNC 2022 (this study),
# RNC 2014 (Mashanov et al. 2014, SRA), intestine collaborator (unpublished).
# Output BAM is indexed and sorted — ready for BRAKER3.

set -euo pipefail

GENOME=Hglab_hic_2023_v4.soft_masked.fa
INDEX=star_index
THREADS=16

# ---- 1. Build index (once) -------------------------------------------------
if [[ ! -d "${INDEX}" ]]; then
    mkdir -p "${INDEX}"
    STAR --runMode genomeGenerate \
         --genomeDir "${INDEX}" \
         --genomeFastaFiles "${GENOME}" \
         --runThreadN "${THREADS}" \
         --genomeSAindexNbases 13
fi

# ---- 2. Align --------------------------------------------------------------
# Usage: star_align.sh <sample_prefix> <R1.fq.gz> <R2.fq.gz>
SAMPLE=$1
R1=$2
R2=$3

STAR --runThreadN "${THREADS}" \
     --genomeDir "${INDEX}" \
     --readFilesIn "${R1}" "${R2}" \
     --readFilesCommand zcat \
     --outFileNamePrefix "${SAMPLE}_" \
     --outSAMtype BAM SortedByCoordinate \
     --twopassMode Basic \
     --outSAMstrandField intronMotif

samtools index "${SAMPLE}_Aligned.sortedByCoord.out.bam"
