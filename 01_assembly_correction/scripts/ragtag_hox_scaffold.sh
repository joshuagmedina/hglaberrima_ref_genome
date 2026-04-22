#!/bin/bash
#SBATCH --job-name=RagScaffoldHox
#SBATCH --mem-per-cpu=7500
#SBATCH --time=7-00:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=14

# Reference-guided rescaffolding of the Hox-containing scaffolds against
# the v2.2 draft assembly.
#
# Requires: RagTag (conda: bioconda::ragtag)
# Activate the conda environment that provides ragtag.py before running.

set -euo pipefail

# source "$(conda info --base)/etc/profile.d/conda.sh"
# conda activate ragtag_env

REF=00-REF/Hglab.v2.2.genome.fa
QRY=../hox-scaffolds.refg.fa
OUT=./01-RAG-TAG-RESULTS

ragtag.py scaffold "${REF}" "${QRY}" -o "${OUT}"
