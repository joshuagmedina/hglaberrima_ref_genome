#!/usr/bin/env python3
"""Write per-scaffold lengths and the total genome length to a TSV.

Usage:
    python scaffold_lengths.py --fasta Hglab_hic_2023_v4_final.sorted.fasta \
                               --out   sequence_lengths.tsv
"""
from __future__ import annotations

import argparse
from pathlib import Path

from Bio import SeqIO


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--fasta", required=True, type=Path)
    p.add_argument("--out", required=True, type=Path)
    args = p.parse_args()

    total = 0
    with args.out.open("w") as fh:
        fh.write("sequence_id\tlength\n")
        for record in SeqIO.parse(args.fasta, "fasta"):
            fh.write(f"{record.id}\t{len(record)}\n")
            total += len(record)
        fh.write(f"#total\t{total}\n")
    print(f"Wrote {args.out} (total: {total:,} bp)")


if __name__ == "__main__":
    main()
