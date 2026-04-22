# 06 — Transposable elements

Two independent TE annotation pipelines were run on the final assembly.
Their soft-masked FASTAs are used upstream in
[`../02_gene_annotation`](../02_gene_annotation).

## 6.1 EDTA (primary — used for the manuscript masking)

EDTA v2.1.1 and v2.2.1 were run in the standard three-step mode:

1. De novo identification of LTR, TIR, and Helitron candidates.
2. Consolidated TE library.
3. Whole-genome masking.

```bash
bash edta/run_edta.sh Hglab_hic_2023_v4_final.fasta
```

Internal tools EDTA dispatches: `LTR_FINDER`, `LTRharvest`,
`LTR_retriever`, `HelitronScanner`, plus an optional `RepBase` merge.
The final soft-masked genome used for BRAKER3 is
`Hglab_hic_2023_v4.soft_masked.fa`.

## 6.2 RepeatModeler + RepeatMasker (alternative)

Kept for reproducibility and to generate the classification-based
statistics reported in the Supplementary. Note this pipeline masks
everything EDTA misses; the EDTA masked genome is the canonical input
to annotation.

```bash
bash repeatmasker/run_repeatmodeler.sh Hglab_hic_2023_v4_final.fasta
bash repeatmasker/run_repeatmasker.sh  Hglab_hic_2023_v4_final.fasta combined.lib.fa
```

## 6.3 TE-proximal genes (Figure 4)

[`TEclosest_genes.Rmd`](TEclosest_genes.Rmd) generates the distance-to-
nearest-gene histogram and the Gypsy-vs-gene-expression panel. Inputs:

- `EDTA.TEanno.gff3` from 6.1
- Final annotation GFF3 from [`../02_gene_annotation`](../02_gene_annotation)
- Gene expression TPM matrix (Stringtie `prepDE.py` output)

## Files

- [`edta/run_edta.sh`](edta/run_edta.sh) — full EDTA pipeline wrapper.
- [`repeatmasker/run_repeatmodeler.sh`](repeatmasker/run_repeatmodeler.sh)
- [`repeatmasker/run_repeatmasker.sh`](repeatmasker/run_repeatmasker.sh)
- [`TEclosest_genes.Rmd`](TEclosest_genes.Rmd) — TE–gene proximity analysis.
