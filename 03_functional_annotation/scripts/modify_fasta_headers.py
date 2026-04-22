#!/usr/bin/env python3
"""Clean BRAKER/EVM protein FASTA headers.

BRAKER/EVM protein FASTAs often contain multiple whitespace-delimited
fields and `.t1` / `.p1` suffixes. Keep only the primary identifier
(everything up to the first whitespace and strip trailing `.t*` / `.p*`).

Usage:
    python modify_fasta_headers.py --in evm.proteins.fa --out evm.proteins.clean.fa
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

TRAILING = re.compile(r"\.(?:t|p)\d+$")


def clean(in_fa: Path, out_fa: Path) -> None:
    with in_fa.open() as src, out_fa.open("w") as dst:
        for line in src:
            if line.startswith(">"):
                header = line[1:].strip().split()[0]
                header = TRAILING.sub("", header)
                dst.write(f">{header}\n")
            else:
                dst.write(line)


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--in", dest="in_fa", required=True, type=Path)
    p.add_argument("--out", dest="out_fa", required=True, type=Path)
    args = p.parse_args()
    clean(args.in_fa, args.out_fa)


if __name__ == "__main__":
    main()
