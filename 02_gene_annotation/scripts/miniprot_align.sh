#!/bin/bash
# miniprot v0.12 cross-species protein alignment.
# Used to produce two protein-evidence GFFs for EVM:
#   - spur_miniprot.gff (Strongylocentrotus purpuratus RefSeq proteins)
#   - hleu_miniprot.gff (Holothuria leucospilota GenBank proteins)

set -euo pipefail

GENOME=${1:?usage: miniprot_align.sh <genome.fa> <proteins.pep.fa> <out.gff>}
PEP=${2:?missing proteins}
OUT=${3:?missing output}
THREADS=${4:-16}

INDEX="${GENOME%.fa*}.mpi"

if [[ ! -s "${INDEX}" ]]; then
    miniprot -t "${THREADS}" -d "${INDEX}" "${GENOME}"
fi

miniprot -t "${THREADS}" --gff "${INDEX}" "${PEP}" > "${OUT}"
