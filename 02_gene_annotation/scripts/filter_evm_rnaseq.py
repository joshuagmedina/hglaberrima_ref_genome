#!/usr/bin/env python3
"""Drop EVM predictions supported *only* by transcript (RNA-seq) evidence.

After running EVidenceModeler, some genes in the combined GFF3 are
supported only by PASA/Stringtie transcript evidence with no matching
ab initio prediction or protein alignment. This script keeps a
prediction only if at least one non-TRANSCRIPT evidence source supports
it.

Usage:
    python filter_evm_rnaseq.py evm_output.gff3 evm_filtered.gff3
"""
from __future__ import annotations

import sys
from collections import defaultdict


def main(in_gff: str, out_gff: str) -> None:
    gene_to_sources: dict[str, set[str]] = defaultdict(set)
    gene_lines: dict[str, list[str]] = defaultdict(list)

    with open(in_gff) as fh:
        for line in fh:
            if line.startswith("#") or not line.strip():
                continue
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 9:
                continue
            source = parts[1]
            attrs = parts[8]
            gene_id = _attr(attrs, "ID") or _attr(attrs, "Parent")
            if gene_id is None:
                continue
            root = gene_id.split(".")[0]
            gene_to_sources[root].add(source)
            gene_lines[root].append(line)

    transcript_sources = {"PASA", "transdecoder", "assembler-hglab_pasa_v1.sqlite"}
    with open(out_gff, "w") as fh:
        for gene, sources in gene_to_sources.items():
            non_transcript = sources - transcript_sources
            if not non_transcript:
                continue
            for line in gene_lines[gene]:
                fh.write(line)


def _attr(attrs: str, key: str) -> str | None:
    for entry in attrs.split(";"):
        entry = entry.strip()
        if entry.startswith(f"{key}="):
            return entry.split("=", 1)[1]
    return None


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(f"usage: {sys.argv[0]} <in.gff3> <out.gff3>")
    main(sys.argv[1], sys.argv[2])
