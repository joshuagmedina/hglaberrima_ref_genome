#!/bin/bash
# RepeatMasker v4.1.5 with a species-specific library.
# Produces a soft-masked genome + .out/.gff/.tbl summaries.

set -euo pipefail

GENOME=${1:?usage: run_repeatmasker.sh <genome.fa> <lib.fa> [threads]}
LIB=${2:?missing library}
THREADS=${3:-32}

RepeatMasker \
    -pa "${THREADS}" \
    -lib "${LIB}" \
    -xsmall \
    -gff \
    -dir repeatmasker_out \
    "${GENOME}"
