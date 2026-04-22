#!/usr/bin/env python3
"""Rename scaffold/chromosome IDs in a GFF/GTF using a mapping CSV.

Used immediately before NCBI submission to swap the internal working
scaffold names (Hglab_1 … Hglab_23 plus unplaced scaffolds) for the
NCBI-submitted chromosome names.

mapping_ids.csv columns: original_id,new_id

Usage:
    python gff_chr_rename.py \\
        --gff  augustus_hints_with_utr.gtf \\
        --map  mapping_ids.csv \\
        --out  augustus_hints_with_utr.mod.gtf
"""
from __future__ import annotations

import argparse
import csv
from pathlib import Path


def load_mapping(path: Path) -> dict[str, str]:
    with path.open(newline="") as fh:
        reader = csv.DictReader(fh)
        return {row["original_id"]: row["new_id"] for row in reader}


def rewrite(gff: Path, mapping: dict[str, str], out: Path) -> None:
    with gff.open() as src, out.open("w") as dst:
        for line in src:
            if line.startswith("#") or not line.strip():
                dst.write(line)
                continue
            parts = line.rstrip("\n").split("\t")
            if parts and parts[0] in mapping:
                parts[0] = mapping[parts[0]]
            dst.write("\t".join(parts) + "\n")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--gff", required=True, type=Path)
    p.add_argument("--map", required=True, type=Path, dest="mapping")
    p.add_argument("--out", required=True, type=Path)
    args = p.parse_args()
    mapping = load_mapping(args.mapping)
    rewrite(args.gff, mapping, args.out)


if __name__ == "__main__":
    main()
