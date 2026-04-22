#!/bin/bash
# BLASTp query against a UniProt BLAST database (SwissProt or TrEMBL).
# Output format matches what scripts/parse_uniprot_fasta.py expects.
#
# Usage: blastp_uniprot.sh <query.fa> <db_prefix> <out.tsv> [threads]

set -euo pipefail

QUERY=${1:?query fasta}
DB=${2:?blast db prefix}
OUT=${3:?output tsv}
THREADS=${4:-16}

blastp \
    -query "${QUERY}" \
    -db "${DB}" \
    -out "${OUT}" \
    -num_threads "${THREADS}" \
    -evalue 1e-5 \
    -max_target_seqs 1 \
    -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle'
