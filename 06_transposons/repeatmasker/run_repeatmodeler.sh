#!/bin/bash
# RepeatModeler v2.0.5 — de novo repeat library for H. glaberrima v4.
# Output library: RM_*/consensi.fa.classified

set -euo pipefail

GENOME=${1:?usage: run_repeatmodeler.sh <genome.fa>}
DB=hglab_v4
THREADS=${2:-32}

BuildDatabase -name "${DB}" "${GENOME}"
RepeatModeler -database "${DB}" -threads "${THREADS}" -LTRStruct
