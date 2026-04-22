#!/bin/bash
# Combine independent BRAKER runs with TSEBRA v1.1.2.2.
# Only used if more than one BRAKER prediction set exists (e.g. metazoan
# protein run + eumetazoa/deuterostomia run). For the manuscript a single
# BRAKER3 ETP run was kept, but the TSEBRA call is retained for
# reproducibility of exploratory comparisons.

set -euo pipefail

TSEBRA=/opt/TSEBRA/bin/tsebra.py

${TSEBRA} \
    -g run1/braker.gtf,run2/braker.gtf \
    -c /opt/TSEBRA/config/default.cfg \
    -e run1/hintsfile.gff,run2/hintsfile.gff \
    -o braker_combined.gtf
