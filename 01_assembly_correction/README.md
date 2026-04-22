# 01 — Assembly correction (Hglab v2 → v4)

This section reproduces the **manual correction of the Hox9 region** and
the subsequent scaffolding steps that produce the final 23-scaffold
chromosome-scale assembly (`Hglab_hic_2023_v4_final.fasta`).

## Background

The initial HiRise/Omni-C assembly (`Hglab.v2.2.genome.fa`, here called
"draft") placed the Hox9 ortholog on scaffold `Hglab.00016`. In the
re-assembled genome (`Hglab.hic.genome.2023.mod.fa`), the region
containing Hox9 was **missing from scaffold `ScTXNHT_2`** between
positions 11,748,739 and ~11,795,046. A nucmer alignment of
`ScTXNHT_2` against `Hglab.00016` confirmed the gap. The region was
rescued from the draft, inserted back into `ScTXNHT_2`, and the
rescaffolded assembly was validated against the draft with SSPACE and
RagTag.

Inputs: `ScTXNHT_2.fa` (region of the new assembly),
`Hglab.00016.fa` (draft scaffold carrying Hox9), artificial mate-pair
libraries at 3 / 5 / 8 / 20 kb from the draft assembly.

## Pipeline

1. **Identify the gap** — align the new scaffold to the draft with nucmer.
   ```bash
   sbatch scripts/nucmer_scTXNHT2_vs_draft.sh
   # produces hox9_analysis.delta → dnadiff for %identity / coverage
   ```
2. **Extract the missing segment** from the draft with `samtools faidx`:
   ```bash
   samtools faidx Hglab.00016.fa Hglab.00016:2999-46306 \
       > Hglab.00016_2999-46306.fasta
   ```
3. **Insert the segment** at position 11,748,739 of `ScTXNHT_2`:
   ```bash
   python scripts/insert_sequence.py \
       --reference ScTXNHT_2.fa \
       --insert Hglab.00016_2999-46306.fasta \
       --position 11748739 \
       --out ScTXNHT_2.hox9_fixed.fasta
   ```
4. **Generate artificial mate-pair libraries** from the draft assembly
   with matemaker v1.2 (see `configs/sspace_libraries.txt`) and run
   SSPACE Standard v3.0:
   ```bash
   sbatch scripts/sspace_hox_scaffold.sh
   ```
5. **Reference-guided rescaffolding** with RagTag against the draft:
   ```bash
   sbatch scripts/ragtag_hox_scaffold.sh
   ```
6. **Validation** — align the corrected assembly back to the draft
   with minimap2 v2.22 and produce the alignment R/Rmd plot in
   [`07_figures/`](../07_figures/).

## Software

- mummer v4.0.0 (nucmer, dnadiff)
- samtools ≥1.15 (faidx)
- SSPACE Standard v3.0
- matemaker v1.2
- RagTag (latest)
- BWA (read mapping for SSPACE)
- Biopython (for `insert_sequence.py`)

## Notes on superseded approaches

Earlier attempts to patch the assembly with **Pilon** and pure long-read
polishing did not recover the Hox9 region and are intentionally omitted.
See `GAPS_REPORT.md` (outside this repo) for details.

## Files

- [`scripts/insert_sequence.py`](scripts/insert_sequence.py) — insert a
  donor FASTA into a target FASTA at a user-specified coordinate.
- [`scripts/nucmer_scTXNHT2_vs_draft.sh`](scripts/nucmer_scTXNHT2_vs_draft.sh)
  — SLURM wrapper for nucmer + dnadiff.
- [`scripts/sspace_hox_scaffold.sh`](scripts/sspace_hox_scaffold.sh) —
  SLURM wrapper for SSPACE v3.0 using artificial mate pairs.
- [`scripts/ragtag_hox_scaffold.sh`](scripts/ragtag_hox_scaffold.sh) —
  SLURM wrapper for `ragtag.py scaffold`.
- [`configs/sspace_libraries.txt`](configs/sspace_libraries.txt) —
  SSPACE library manifest (3/5/8/20 kb artificial mate pairs).
