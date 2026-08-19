#!/usr/bin/env bash
# merqury_qv.sh — consensus accuracy (QV) and k-mer completeness
#
# Compares a meryl k-mer DB (from kmer_genomescope.sh) against the assembly.
# Only valid if the k-mer reads and the assembly are from the same individual.
#
# Usage:
#   merqury_qv.sh <assembly.fa> <meryl_db> <outdir> <outprefix>
set -euo pipefail

ASM=${1:?usage: merqury_qv.sh <assembly.fa> <meryl_db> <outdir> <outprefix>}
MERYL_DB=${2:?missing meryl_db}
OUT=${3:?missing outdir}
PREFIX=${4:?missing outprefix}

mkdir -p "$OUT"; cd "$OUT"
# symlink, do NOT cp -r — meryl DBs are tens of GB
[[ -e "$(basename "$MERYL_DB")" ]] || ln -s "$MERYL_DB" "$(basename "$MERYL_DB")"
merqury.sh "$(basename "$MERYL_DB")" "$ASM" "$PREFIX"

echo ">> QV:           $OUT/${PREFIX}.qv"
echo ">> completeness: $OUT/${PREFIX}.completeness.stats"
echo ">> spectra-cn plot: $OUT/${PREFIX}.spectra-cn.ln.png"
