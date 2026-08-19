#!/usr/bin/env bash
# hic_contact_map.sh — Omni-C/Hi-C contact map
#
# bwa mem -5SP -> pairtools parse/sort/dedup/split -> PretextMap/PretextSnapshot.
# pairtools sort can spill ~100 GB of pairsam to TMPDIR for a large library;
# point it at a volume with enough free space (speed doesn't matter much).
#
# Usage:
#   hic_contact_map.sh <assembly.fa> <R1.fastq.gz> <R2.fastq.gz> <outdir> [threads] [tmpdir]
set -euo pipefail

ASM=${1:?usage: hic_contact_map.sh <assembly.fa> <R1.fastq.gz> <R2.fastq.gz> <outdir> [threads] [tmpdir]}
R1=${2:?missing R1}
R2=${3:?missing R2}
OUT=${4:?missing outdir}
THREADS=${5:-16}
TMPDIR=${6:-$OUT/tmp}

mkdir -p "$OUT" "$TMPDIR"
cd "$OUT"

samtools faidx "$ASM"
cut -f1,2 "${ASM}.fai" > genome.chrom.sizes

if [[ ! -f "${ASM}.bwt" ]]; then
  echo ">> building bwa index"
  bwa index "$ASM"
fi

bwa mem -5SP -T0 -t "$THREADS" "$ASM" "$R1" "$R2" \
 | pairtools parse --min-mapq 40 --walks-policy 5unique \
     --max-inter-align-gap 30 --nproc-in "$THREADS" --nproc-out "$THREADS" \
     --chroms-path genome.chrom.sizes \
 | pairtools sort --nproc "$THREADS" --tmpdir="$TMPDIR" \
 | pairtools dedup --nproc-in "$THREADS" --nproc-out "$THREADS" \
     --mark-dups --output-stats stats.txt \
 | pairtools split --nproc-in "$THREADS" --nproc-out "$THREADS" \
     --output-pairs mapped.pairs --output-sam - \
 | samtools sort -@ "$THREADS" -T "$TMPDIR/samsort" -o mapped.PT.bam
samtools index mapped.PT.bam

# mapped.PT.bam is not usable for variant calling (hard-clipped chimera
# records) — use heterozygosity_omnic.sh for that instead.

samtools view -h mapped.PT.bam \
 | PretextMap -o contact_map.pretext --sortby length --sortorder descend --mapq 10
PretextSnapshot -m contact_map.pretext -o . --sequences "=full" || true

echo ">> stats: $OUT/stats.txt"
echo ">> pairs: $OUT/mapped.pairs  (input to plot_contact_map.py)"
echo ">> raw preview: $OUT/*.png (unlabelled — see plot_contact_map.py for the labelled figure)"
