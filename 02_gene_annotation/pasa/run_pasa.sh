#!/bin/bash
# PASA v2.5.3 alignment-assembly run.
# Builds a PASA SQLite database from full-length transcripts (Stringtie
# merged per tissue, filtered with Transdecoder) and produces the
# alignment-assemblies GFF3 used as transcript evidence in EVM.

set -euo pipefail

GENOME=Hglab_hic_2023_v4.soft_masked.fa
TRANSCRIPTS=transcripts_merged.fa
DB=assembler-hglab_pasa_v1.sqlite
CONFIG=alignAssembly.config
THREADS=16

Launch_PASA_pipeline.pl \
    -c "${CONFIG}" \
    -C -R \
    --ALIGNERS gmap,blat \
    -g "${GENOME}" \
    -t "${TRANSCRIPTS}" \
    --CPU "${THREADS}" \
    --TRANSDECODER
