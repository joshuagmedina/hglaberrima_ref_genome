#!/usr/bin/env python3
"""Apply UniProt mapping to the protein FASTA and the annotation GFF3.

- FASTA: rewrite headers so they carry the best-hit UniProt annotation:
    >Hglab.XXX product="..." gene="..." uniprot=ACC organism="..."

- GFF3: append to the `attributes` column of every `mRNA`/`gene`
  feature whose ID matches a query:
    ;product=...;Note=UniProt:ACC gene ...

Input `--map` TSV is produced by parse_uniprot_fasta.py.
"""
from __future__ import annotations

import argparse
import csv
from pathlib import Path


def load_map(path: Path) -> dict[str, dict[str, str]]:
    out: dict[str, dict[str, str]] = {}
    with path.open(newline="") as fh:
        for row in csv.DictReader(fh, delimiter="\t"):
            out[row["query"]] = row
    return out


def rewrite_fasta(in_fa: Path, mapping: dict[str, dict[str, str]],
                  out_fa: Path) -> None:
    with in_fa.open() as src, out_fa.open("w") as dst:
        for line in src:
            if line.startswith(">"):
                header = line[1:].strip().split()[0]
                info = mapping.get(header)
                if info:
                    dst.write(
                        f'>{header} product="{info["product"]}" '
                        f'gene="{info["gene"]}" '
                        f'uniprot={info["uniprot_acc"]} '
                        f'organism="{info["organism"]}"\n'
                    )
                else:
                    dst.write(line)
            else:
                dst.write(line)


def rewrite_gff(in_gff: Path, mapping: dict[str, dict[str, str]],
                out_gff: Path) -> None:
    with in_gff.open() as src, out_gff.open("w") as dst:
        for line in src:
            if line.startswith("#") or not line.strip():
                dst.write(line)
                continue
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 9 or parts[2] not in {"mRNA", "gene"}:
                dst.write(line)
                continue
            attrs = dict(_split_attr(parts[8]))
            feature_id = attrs.get("ID") or attrs.get("Parent", "")
            info = mapping.get(feature_id)
            if info and info["uniprot_acc"]:
                attrs["product"] = info["product"] or "hypothetical protein"
                note = f'UniProt:{info["uniprot_acc"]}'
                if info["gene"]:
                    note += f' gene={info["gene"]}'
                attrs["Note"] = note
                parts[8] = ";".join(f"{k}={v}" for k, v in attrs.items())
            dst.write("\t".join(parts) + "\n")


def _split_attr(attrs: str):
    for entry in attrs.split(";"):
        entry = entry.strip()
        if not entry:
            continue
        if "=" in entry:
            k, v = entry.split("=", 1)
            yield k, v


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--fasta", required=True, type=Path)
    p.add_argument("--gff", required=True, type=Path)
    p.add_argument("--map", required=True, type=Path, dest="mapping")
    p.add_argument("--out-fasta", required=True, type=Path)
    p.add_argument("--out-gff", required=True, type=Path)
    args = p.parse_args()

    mapping = load_map(args.mapping)
    rewrite_fasta(args.fasta, mapping, args.out_fasta)
    rewrite_gff(args.gff, mapping, args.out_gff)


if __name__ == "__main__":
    main()
