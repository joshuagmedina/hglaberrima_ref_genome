#!/bin/bash
# EDTA v2.1.1 / v2.2.1 — TE annotation for H. glaberrima v4.
# Runs the three-step protocol: raw discovery, final library, genome masking.
#
# Usage: run_edta.sh <genome.fa> [threads]

set -euo pipefail

GENOME=${1:?usage: run_edta.sh <genome.fa>}
THREADS=${2:-32}
BASE=$(basename "${GENOME}" .fa)
BASE=${BASE%.fasta}

# Step 1 — raw candidates (LTR_FINDER + LTRharvest + LTR_retriever + HelitronScanner + TIR)
EDTA_raw.pl \
    --genome "${GENOME}" \
    --threads "${THREADS}" \
    --type all

# Step 2 — final consolidated library + whole-genome masking
EDTA.pl \
    --genome "${GENOME}" \
    --species others \
    --step all \
    --sensitive 1 \
    --anno 1 \
    --threads "${THREADS}"

# Step 3 — produce a hard + soft masked genome from the EDTA annotation
make_masked.pl \
    -genome "${GENOME}" \
    -rmout "${GENOME}.mod.EDTA.anno/${BASE}.mod.EDTA.TEanno.out" \
    -maxdiv 40 \
    -minlen 80 \
    -t "${THREADS}"
