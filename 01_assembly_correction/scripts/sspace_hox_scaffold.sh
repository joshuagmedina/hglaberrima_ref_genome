#!/bin/bash
#SBATCH --job-name=HoxScaffoldwDraft
#SBATCH --mem-per-cpu=7500
#SBATCH --time=7-00:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16

# SSPACE Standard v3.0 rescaffolding of the Hox-containing region using
# artificial mate pairs generated from the draft assembly with matemaker.
# See configs/sspace_libraries.txt for the library manifest.
#
# Requires: SSPACE Standard v3.0 (Boetzer et al., Bioinformatics 2011)
#           BWA (for read mapping inside SSPACE)
# Set SSPACE_DIR to the directory containing SSPACE_Standard_v3.0.pl.

set -euo pipefail

# Activate the conda environment that provides BWA (adjust as needed)
# source "$(conda info --base)/etc/profile.d/conda.sh"
# conda activate sspace_env

# Path to SSPACE_Standard_v3.0.pl — set before running
SSPACE_DIR=/path/to/SSPACE-STANDARD-3.0_linux-x86_64
SSPACE="${SSPACE_DIR}/SSPACE_Standard_v3.0.pl"

INPUT=hox-scaffolds.refg.fa            # hox-containing scaffolds to re-link
PREFIX=Hglab_hox_scaffold_sspace

"${SSPACE}" \
    -l ../configs/sspace_libraries.txt \
    -s "${INPUT}" \
    -T 45 \
    -a 0.7 \
    -x 0 \
    -b "${PREFIX}"
