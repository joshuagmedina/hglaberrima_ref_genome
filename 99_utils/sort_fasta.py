#!/usr/bin/env python3
"""Sort a FASTA by sequence length, descending.

Usage:
    python sort_fasta.py --in Hglab_hic_2023_v4_final.fasta \
                         --out Hglab_hic_2023_v4_final.sorted.fasta
"""
from __future__ import annotations

import argparse
from pathlib import Path

from Bio import SeqIO


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--in", dest="in_fa", required=True, type=Path)
    p.add_argument("--out", dest="out_fa", required=True, type=Path)
    args = p.parse_args()

    records = sorted(SeqIO.parse(args.in_fa, "fasta"),
                     key=lambda r: len(r), reverse=True)
    with args.out_fa.open("w") as fh:
        SeqIO.write(records, fh, "fasta")


if __name__ == "__main__":
    main()
