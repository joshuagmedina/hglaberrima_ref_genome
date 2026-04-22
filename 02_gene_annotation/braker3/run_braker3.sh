#!/bin/bash
# BRAKER3 (ETP mode) — RNA-seq + OrthoDB v11 Metazoa proteins.
#
# Software: BRAKER v3.0.7, GeneMark-ETP v1.02, Augustus v3.5.0,
#           ProtHint v2.6.0, TSEBRA v1.1.2.2, GUSHR.

set -euo pipefail

GENOME=Hglab_hic_2023_v4.soft_masked.fa
PROTEINS=orthodb_v11_Metazoa.fa       # ProtHint input
# Four BAM files: intestine (this study), RNC 2022 (this study),
# RNC 2014 (Mashanov et al. 2014), intestine collaborator (unpublished)
BAMS=intestine_Aligned.sortedByCoord.out.bam,rnc2022_Aligned.sortedByCoord.out.bam,rnc2014_Aligned.sortedByCoord.out.bam,collab_intestine_Aligned.sortedByCoord.out.bam
SPECIES=hglab_v4
WORKDIR=braker_hglab_v4
THREADS=32

braker.pl \
    --genome="${GENOME}" \
    --bam="${BAMS}" \
    --prot_seq="${PROTEINS}" \
    --species="${SPECIES}" \
    --workingdir="${WORKDIR}" \
    --threads="${THREADS}" \
    --softmasking \
    --gff3 \
    --UTR=on \
    --addUTR=on
