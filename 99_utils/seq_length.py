#!/usr/bin/env python3
"""Print the length of a single record in a FASTA file.

Usage:
    python seq_length.py --fasta Hglab.hic.genome.2023.mod.sline.fa --id ScTXNHT_2
"""
from __future__ import annotations

import argparse
from pathlib import Path

from Bio import SeqIO


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--fasta", required=True, type=Path)
    p.add_argument("--id", required=True, dest="sequence_id")
    args = p.parse_args()

    for record in SeqIO.parse(args.fasta, "fasta"):
        if record.id == args.sequence_id:
            print(len(record))
            return
    raise SystemExit(f"record {args.sequence_id!r} not found in {args.fasta}")


if __name__ == "__main__":
    main()
