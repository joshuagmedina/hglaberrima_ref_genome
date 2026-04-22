#!/bin/bash
#SBATCH --job-name=HOX9_nucmer
#SBATCH --mem-per-cpu=7500
#SBATCH --time=7-00:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=14
# Aligns the new assembly scaffold ScTXNHT_2 to the draft scaffold
# Hglab.00016 (which carries Hox9) to identify the missing region.
# Produces hox9_analysis.delta and a dnadiff report.

set -euo pipefail

module load mummer    # mummer v4.0.0

REF=ScTXNHT_2.fa            # new assembly scaffold
QRY=draft.00016.fa          # draft scaffold carrying Hox9 (Hglab.00016)
PREFIX=hox9_analysis

nucmer --mum -p "${PREFIX}" "${REF}" "${QRY}"
dnadiff -d "${PREFIX}.delta" -p "${PREFIX}_dnadiff"
