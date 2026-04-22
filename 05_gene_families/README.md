# 05 — Gene family analyses

Manuscript Section covering the manual curation / cataloguing of the
gene families highlighted in Figure 3 and Supplementary Table S5.

## 5.1 Hox cluster verification

The corrected v4 assembly restores the full Hox cluster on chromosome
`Hglab_2` (scaffold `ScTXNHT_2`), including the previously missing Hox9
copy. Reference Hox peptides are searched against the scaffold using tblastn
to verify cluster integrity:

```bash
makeblastdb -in Hglab_hic_2023_v4_final.fasta -dbtype nucl -out db/hglab_v4
tblastn -query data/hox_reference.fa -db db/hglab_v4 -evalue 1e-5 \
        -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore' \
        -out hox/hox_tblastn.tsv
```

The scaffold alignment plot (Figure 1C) is generated in
[`../07_figures/nucmer-scaffold-alignment-plot.Rmd`](../07_figures/nucmer-scaffold-alignment-plot.Rmd).

## 5.2 THAP transcription factors — CREPE cataloguing

THAP-domain transcription factors across sea cucumber and reference
metazoan proteomes were catalogued with
[CREPE](https://github.com/joshuagmedina/CREPE) — our semi-automated
domain search pipeline. The per-species CREPE output (CSV) is then
filtered for THAP hits and the corresponding sequences extracted from
each proteome.

Steps:

```bash
# 1. Run CREPE per species (outputs: <species>.csv). See CREPE docs.

# 2. Pull THAP entries out of each CREPE CSV and write one ID list per species:
bash thap_crepe/thap_seqs.ids.sh

# 3. Extract the corresponding FASTA sequences per species:
bash thap_crepe/get_thap_seqs.sh     # prompts for ids_list and sequences.fa

# 4. Run downstream analysis + figure:
Rscript -e 'rmarkdown::render("thap_crepe/CREPE_Data_Processing.Rmd")'
```

## Files

- [`thap_crepe/CREPE_Data_Processing.Rmd`](thap_crepe/CREPE_Data_Processing.Rmd)
  — CREPE post-processing, THAP gene counting, MSA prep for IQ-TREE.
- [`thap_crepe/thap_seqs.ids.sh`](thap_crepe/thap_seqs.ids.sh) —
  extract THAP IDs from per-species CREPE CSV.
- [`thap_crepe/get_thap_seqs.sh`](thap_crepe/get_thap_seqs.sh) — pull
  FASTA records for a given ID list.

## Phylogeny (for Figure 3)

Alignment/tree commands applied to the THAP cohort:

```bash
mafft --maxiterate 1000 --localpair thap_seqs.fa > thap_seqs.aln.fa
iqtree2 -s thap_seqs.aln.fa -m MFP -bb 1000 -alrt 1000 -T AUTO -pre thap_tree
```
