#!/usr/bin/env python3
"""Join BLASTp hits against UniProt with UniProt metadata.

Reads the BLASTp output produced by `blastp_uniprot.sh` and the source
UniProt FASTA (SwissProt or TrEMBL). For every query, writes a TSV row:

    query_id  uniprot_acc  gene_symbol  organism  product_name  evalue  bitscore

UniProt FASTA headers look like::

    >sp|O00555|CAC1A_HUMAN Voltage-dependent P/Q-type calcium channel subunit ... OS=Homo sapiens OX=9606 GN=CACNA1A PE=1 SV=3

so we parse `OS=`, `GN=` and the description between the accession and
the first `OS=`.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path


GN = re.compile(r"GN=([^\s]+)")
OS = re.compile(r"OS=(.+?)(?:\sOX=|\sGN=|\sPE=|\sSV=|$)")


def parse_uniprot(path: Path) -> dict[str, tuple[str, str, str, str]]:
    """Return uniprot_acc -> (gene, organism, product, full_header)."""
    meta: dict[str, tuple[str, str, str, str]] = {}
    with path.open() as fh:
        for line in fh:
            if not line.startswith(">"):
                continue
            header = line[1:].rstrip("\n")
            # sp|ACC|NAME description...
            fields = header.split("|", 2)
            acc = fields[1] if len(fields) >= 2 else header.split()[0]
            tail = fields[2] if len(fields) == 3 else ""
            # Product name is everything up to the first annotation tag
            product = re.split(r"\sOS=|\sOX=|\sGN=|\sPE=|\sSV=", tail, 1)[0]
            product = product.split(None, 1)[1] if " " in product else product
            gene = (GN.search(tail).group(1) if GN.search(tail) else "")
            organism = (OS.search(tail).group(1) if OS.search(tail) else "")
            meta[acc] = (gene, organism, product, header)
    return meta


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--blast", required=True, type=Path,
                   help="BLASTp tabular output from blastp_uniprot.sh")
    p.add_argument("--uniprot", required=True, type=Path,
                   help="UniProt SwissProt/TrEMBL FASTA")
    p.add_argument("--out", required=True, type=Path)
    args = p.parse_args()

    meta = parse_uniprot(args.uniprot)

    with args.blast.open() as src, args.out.open("w") as dst:
        dst.write("query\tuniprot_acc\tgene\torganism\tproduct\tevalue\tbitscore\n")
        for line in src:
            cols = line.rstrip("\n").split("\t")
            if len(cols) < 12:
                continue
            query, sseqid = cols[0], cols[1]
            evalue, bitscore = cols[10], cols[11]
            # sseqid might be sp|ACC|NAME or just ACC
            acc = sseqid.split("|")[1] if "|" in sseqid else sseqid
            gene, organism, product, _ = meta.get(acc, ("", "", "", ""))
            dst.write(f"{query}\t{acc}\t{gene}\t{organism}\t{product}\t{evalue}\t{bitscore}\n")


if __name__ == "__main__":
    main()
