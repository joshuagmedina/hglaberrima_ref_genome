#!/usr/bin/env python3
"""Split a length-sorted FASTA into the first N and remaining records.

Default N=23 — used to separate the 23 chromosome-scale scaffolds of
H. glaberrima v4 from the unplaced scaffolds.

Usage:
    python split_fasta.py --in sorted.fasta --n 23 \
        --first chromosomes.fasta --rest smaller.fasta
"""
from __future__ import annotations

import argparse
from pathlib import Path

from Bio import SeqIO


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--in", dest="in_fa", required=True, type=Path)
    p.add_argument("--n", type=int, default=23)
    p.add_argument("--first", required=True, type=Path)
    p.add_argument("--rest", required=True, type=Path)
    args = p.parse_args()

    records = list(SeqIO.parse(args.in_fa, "fasta"))
    with args.first.open("w") as fh:
        SeqIO.write(records[: args.n], fh, "fasta")
    with args.rest.open("w") as fh:
        SeqIO.write(records[args.n:], fh, "fasta")
    print(f"Wrote {args.n} records to {args.first} and "
          f"{len(records) - args.n} to {args.rest}")


if __name__ == "__main__":
    main()
