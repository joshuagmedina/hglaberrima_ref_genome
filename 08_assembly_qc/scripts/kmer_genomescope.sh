#!/usr/bin/env bash
# kmer_genomescope.sh — k-mer genome size / heterozygosity estimate
#
# meryl k-mer counting + GenomeScope2 on any Illumina-quality read set.
# Leaves the meryl DB in <outdir>/<label>.meryl for reuse by merqury_qv.sh.
#
# Usage:
#   kmer_genomescope.sh <outdir> <label> <k> <ploidy> <threads> <mem_gb> <r1> [r2 ...]
set -euo pipefail

OUT=${1:?usage: kmer_genomescope.sh <outdir> <label> <k> <ploidy> <threads> <mem_gb> <r1> [r2 ...]}
LABEL=${2:?missing label}
K=${3:?missing k}
PLOIDY=${4:?missing ploidy}
THREADS=${5:?missing threads}
MEM_GB=${6:?missing mem_gb}
shift 6
READS=("$@")
[[ ${#READS[@]} -ge 1 ]] || { echo "!! at least one read file required"; exit 1; }

mkdir -p "$OUT"

meryl count k="$K" threads="$THREADS" memory="$MEM_GB" \
      "${READS[@]}" output "$OUT/${LABEL}.meryl"
meryl histogram "$OUT/${LABEL}.meryl" > "$OUT/${LABEL}.histo"

genomescope2 -i "$OUT/${LABEL}.histo" -o "$OUT/genomescope_${LABEL}" \
      -k "$K" -p "$PLOIDY" -n "$LABEL" || echo "!! GenomeScope2 failed to converge"

echo ">> summary: $OUT/genomescope_${LABEL}/${LABEL}_summary.txt"
echo ">> meryl DB (reuse for merqury_qv.sh): $OUT/${LABEL}.meryl"
