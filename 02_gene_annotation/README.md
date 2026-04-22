# 02 — Gene annotation

Full gene annotation pipeline used to produce the official
*H. glaberrima* v4 annotation. Order of operations:

1. **Repeat masking** — see [`../06_transposons`](../06_transposons).
   The soft-masked genome `Hglab_hic_2023_v4.soft_masked.fa` is the
   input to everything below.
2. **RNA-seq alignment** (STAR) for four tissue/time-point datasets.
3. **BRAKER3** — ETP mode with RNA-seq + OrthoDB v11 Metazoa proteins.
4. **TSEBRA** — combine independent BRAKER runs if needed.
5. **miniprot** — cross-species protein alignment (S. purpuratus,
   H. leucospilota) as additional evidence for EVM.
6. **Stringtie + PASA** — transcript assemblies and PASA alignment
   assemblies for training and evidence.
7. **EVM** — merge ab initio, protein, and transcript evidence.
8. **UTR addition** — GUSHR and `stringtie2utr.py`; consolidate
   fragmented UTRs with [`scripts/consolidate_utrs.pl`](scripts/consolidate_utrs.pl).

Software versions are listed in the top-level [README](../README.md).

---

## 2.1 RNA-seq alignment (STAR)

Four datasets were aligned against the soft-masked genome:

| Dataset            | Source                                     |
|--------------------|--------------------------------------------|
| intestine          | this study                                 |
| RNC 2022           | this study (regenerating nervous cord)     |
| RNC 2014           | Mashanov et al. 2014 (public SRA)          |
| intestine (collab) | collaborator dataset (unpublished)         |

See [`braker3/star_align.sh`](braker3/star_align.sh) for the STAR call
(two-pass alignment). Indexed BAMs are the input to BRAKER3.

## 2.2 BRAKER3

Single BRAKER3 run in ETP mode with all four BAMs plus the OrthoDB v11
Metazoa protein set as ProtHint input:

```bash
bash braker3/run_braker3.sh
```

The output `braker.gtf` from `braker/` becomes one of the evidence
streams to EVM.

## 2.3 miniprot — cross-species protein hints

Protein sets used as miniprot evidence:

- *Strongylocentrotus purpuratus* NCBI RefSeq proteins (`spur_miniprot`)
- *Holothuria leucospilota* GenBank proteins (`hleu_miniprot`)

```bash
bash scripts/miniprot_align.sh \
    Hglab_hic_2023_v4.soft_masked.fa \
    data/spur_refseq.pep.fa \
    spur_miniprot.gff
```

## 2.4 PASA transcript assemblies

Full-length transcripts (from Stringtie + Transdecoder) are aligned back
with PASA v2.5.3 to produce PASA alignment assemblies:

```bash
bash pasa/run_pasa.sh
```

Both intestine and RNC transcript assemblies are merged into a single
`assembler-hglab_pasa_v1.sqlite.pasa_assemblies.gff3` used as the PASA
evidence track for EVM.

## 2.5 EVidenceModeler (EVM)

```bash
# 1. Prepare evidence files in evm/inputs/:
#    - gene_predictions.gff3 (AUGUSTUS + GeneMark.hmm, from BRAKER)
#    - transdecoder.gff3 (OTHER_PREDICTION)
#    - protein_alignments.gff3 (spur_miniprot + hleu_miniprot)
#    - transcript_alignments.gff3 (PASA)
#    - weights.txt (see evm/weights.txt)
bash evm/run_evm.sh Hglab_hic_2023_v4.soft_masked.fa
```

EVM is partitioned, run in parallel with xargs, then recombined and
converted to GFF3 — exactly as in the EVM manual. See
[`evm/run_evm.sh`](evm/run_evm.sh).

Optional Python post-filter — drop predictions supported *only* by
RNA-seq evidence when higher-confidence evidence is available:

```bash
python scripts/filter_evm_rnaseq.py evm_output.gff3 filtered.gff3
```

## 2.6 UTR addition and consolidation

UTRs are predicted with GUSHR (included in BRAKER v3.0.7) and refined
with `stringtie2utr.py` using the Stringtie transcript assemblies. Some
transcripts end up with fragmented 5′ / 3′ UTR entries; consolidate them
to a single span per side with:

```bash
perl scripts/consolidate_utrs.pl augustus_hints_with_utr.gtf \
    > augustus_hints_with_utr.consolidated.gtf
```

## 2.7 Final NCBI-ready GFF

Scaffold IDs in the working GFF (e.g. `Hglab_1` … `Hglab_23`) are
renamed to the NCBI-submitted chromosome names before upload:

```bash
python scripts/gff_chr_rename.py \
    --gff  augustus_hints_with_utr.gtf \
    --map  mapping_ids.csv \
    --out  augustus_hints_with_utr.mod.gtf
```

## Files

- [`braker3/star_align.sh`](braker3/star_align.sh) — STAR two-pass alignment wrapper
- [`braker3/run_braker3.sh`](braker3/run_braker3.sh) — BRAKER3 invocation
- [`braker3/tsebra.sh`](braker3/tsebra.sh) — TSEBRA combination (if multiple BRAKERs)
- [`scripts/miniprot_align.sh`](scripts/miniprot_align.sh) — cross-species protein mapping
- [`pasa/run_pasa.sh`](pasa/run_pasa.sh) — PASA alignment assembly
- [`pasa/alignAssembly.config`](pasa/alignAssembly.config) — PASA config
- [`evm/run_evm.sh`](evm/run_evm.sh) — full EVM partition / run / recombine
- [`evm/weights.txt`](evm/weights.txt) — EVM evidence weights used in the manuscript
- [`scripts/consolidate_utrs.pl`](scripts/consolidate_utrs.pl) — UTR fragment consolidation (manuscript-custom)
- [`scripts/filter_evm_rnaseq.py`](scripts/filter_evm_rnaseq.py) — post-EVM filter
- [`scripts/gff_chr_rename.py`](scripts/gff_chr_rename.py) — rename scaffolds in a GFF
