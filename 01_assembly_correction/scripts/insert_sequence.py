#!/usr/bin/env python3
"""Insert a donor FASTA sequence into a reference FASTA at a 1-based position.

Used to restore the Hox9 region (draft scaffold Hglab.00016, coordinates
2999-46306) into the re-assembled scaffold ScTXNHT_2 at position
11,748,739 — i.e. the exact step described in the Methods under
"Assembly correction".

The donor and reference must each be a single-record FASTA (multi-record
inputs are not supported). The output is a single-record FASTA whose
sequence is:

    reference[:position] + donor + reference[position:]

Usage
-----
    python insert_sequence.py \\
        --reference ScTXNHT_2.fa \\
        --insert    Hglab.00016_2999-46306.fasta \\
        --position  11748739 \\
        --out       ScTXNHT_2.hox9_fixed.fasta \\
        --name      ScTXNHT_2_hox9_fixed
"""
from __future__ import annotations

import argparse
from pathlib import Path


def _read_single_fasta(path: Path) -> str:
    seq: list[str] = []
    with path.open() as fh:
        for line in fh:
            if not line.startswith(">"):
                seq.append(line.strip())
    return "".join(seq)


def insert_sequence(reference: Path, donor: Path, position: int, out: Path,
                    record_name: str) -> None:
    ref = _read_single_fasta(reference)
    ins = _read_single_fasta(donor)
    if not 0 <= position <= len(ref):
        raise SystemExit(
            f"position {position} is outside reference length {len(ref)}"
        )
    updated = ref[:position] + ins + ref[position:]
    with out.open("w") as fh:
        fh.write(f">{record_name}\n")
        for i in range(0, len(updated), 80):
            fh.write(updated[i:i + 80] + "\n")
    print(f"Inserted {len(ins):,} bp at position {position:,}. "
          f"Output: {out} ({len(updated):,} bp)")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--reference", required=True, type=Path)
    p.add_argument("--insert", dest="donor", required=True, type=Path)
    p.add_argument("--position", required=True, type=int,
                   help="0-based insertion position in the reference")
    p.add_argument("--out", required=True, type=Path)
    p.add_argument("--name", default="UpdatedSequence",
                   help="FASTA record name for the output (default: UpdatedSequence)")
    args = p.parse_args()
    insert_sequence(args.reference, args.donor, args.position, args.out,
                    args.name)


if __name__ == "__main__":
    main()
