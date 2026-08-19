# 08 — Assembly quality assessment

Quality control for the final assembly: Omni-C/Hi-C contact mapping,
k-mer-based genome size estimation, heterozygosity, consensus accuracy (QV),
and contamination screening.

Assembly under test: `Hglab_hic_2023_v4_final.fasta` (unmasked), span
**1,238,839,633 bp**, 23 chromosome-scale scaffolds + 2,596 unplaced.

## Background — two individuals, one assembly

| Data | Animal | Used for |
|:--|:--|:--|
| PacBio CLR + Omni-C | **A** — the sequenced/assembled animal | the assembly itself |
| Archival Illumina reads (used in [`../01_assembly_correction`](../01_assembly_correction)) | **B** — the draft-genome animal | draft assembly / an earlier scaffolding attempt, never consensus |

## Pipeline

### 1. Omni-C contact map (`hic_contact_map.sh`)

```bash
bash scripts/hic_contact_map.sh \
    Hglab_hic_2023_v4_final.fasta omnic_R1.fastq.gz omnic_R2.fastq.gz \
    out/hic 16
```

bwa mem (`-5SP -T0`) → pairtools parse/sort/dedup/split → PretextMap.
Produces `mapped.pairs`, used by [`plot_contact_map.py`](scripts/plot_contact_map.py)
(step 6) for the labelled figure, and a `.pretext` file for interactive
viewing.

| Metric | Value |
|:--|--:|
| Total read pairs | 226,186,708 |
| Mapped both ends (MAPQ ≥ 40) | 126,598,139 (55.97%) |
| PCR duplicates | 35,279,267 (27.87% of mapped) |
| **Valid pairs (deduplicated)** | **91,318,872** (40.37% of total) |
| *cis* / *trans* pairs | 32,849,903 / 58,468,969 |
| **cis/trans ratio** | 0.562 |
| Long-range *cis* (>10 kb) | 24,787,552 (27.14% of valid) |

23 scaffolds span 1,160,081,312 bp (93.64% of the assembly), as 23 sharp
diagonal blocks with no off-diagonal structure indicating misjoins.

### 2. K-mer genome size (`kmer_genomescope.sh`)

```bash
bash scripts/kmer_genomescope.sh out/genomescope illumina 21 2 6 100 \
    illumina_R1.fastq.gz illumina_R2.fastq.gz
```

meryl (k=21) → GenomeScope2, ploidy 2, on the draft-animal (B) Illumina reads.

| Property | Min | Max |
|:--|--:|--:|
| **Haploid genome length** | 1,190,822,212 bp | 1,192,043,991 bp |
| Model fit | 68.42% | 96.96% |
| Read error rate | 0.327% | — |

~1.19 Gb, 4% below the 1.2388 Gb assembly span — consistent with normal
uncollapsed heterozygosity. This is animal B's genome size; genome size is
well conserved within a species but not identical across individuals.

### 3. Heterozygosity

| Method | Animal | Heterozygosity |
|:--|:--|--:|
| GenomeScope2 / Illumina k-mers | B (draft) | 0.957–0.973% |
| GenomeScope2 / Omni-C k-mers | A (assembled) | 1.018–1.100% *(poor model fit — supporting only)* |
| Mapping / Omni-C — `heterozygosity_omnic.sh` | **A (assembled)** | 0.6445% *(direct, but under-counts)* |

```bash
bash scripts/heterozygosity_omnic.sh \
    Hglab_hic_2023_v4_final.fasta omnic_R1.fastq.gz omnic_R2.fastq.gz \
    out/omnic_het Hglab_1 16
```

### 4. Consensus accuracy (QV) and k-mer completeness (`merqury_qv.sh`)

```bash
bash scripts/merqury_qv.sh Hglab_hic_2023_v4_final.fasta \
    out/genomescope/illumina.meryl out/merqury hglab_merqury_illumina
bash scripts/merqury_qv.sh Hglab_hic_2023_v4_final.fasta \
    out/genomescope/omnic.meryl out/merqury_omnic hglab_merqury_omnic
```

| Metric | Illumina (animal B) — floor | **Omni-C (animal A) — reported** |
|:--|--:|--:|
| **Consensus QV** | 23.1447 | **28.0959** |
| Error rate | 0.485% | **0.155%** |
| **K-mer completeness** | 74.46% | **80.37%** |

QV 28.10 (~99.85% per-base) is the reported consensus accuracy. It is modest
because the assembly is unpolished PacBio CLR consensus; no Racon/Pilon
polishing was applied. Polishing is also not possible with the available
short reads, since they come from animal B.

Completeness 80.37% is itself a floor — proximity-ligation junctions create
chimeric k-mers in the Omni-C reads that are absent from the genome.

### 5. Contamination screening (`contamination_screen.sh`)

**Result: no contamination detected. No sequence was removed.**

An initial whole-genome DIAMOND screen with `--max-target-seqs 1` produced
artefactual output and is not reproduced here: with one hit per scaffold,
several 45–74 Mb chromosome-scale scaffolds were typed from a single protein
hit as *Nicotiana tabacum* / *E. coli*. BlobToolKit's `bestsumorder` taxrule
needs many hits per sequence to aggregate correctly.

The corrected screen restricts the query to the 2,596 unplaced scaffolds
(78,758,321 bp, 6.36% of the assembly — the 23 chromosomes are already
confirmed by the contact map) with `--max-target-seqs 25`:

```bash
bash scripts/contamination_screen.sh \
    Hglab_hic_2023_v4_final.fasta 23 pacbio_cov.bam \
    uniprot_sprot.dmnd new_taxdump/ out/decontam_unplaced 22
```

| Assignment | Scaffolds | bp | % of assembly |
|:--|--:|--:|--:|
| Metazoa | 165 | 17,765,723 | 1.434% |
| Fungi | 55 | 7,427,436 | 0.600% |
| Viruses | 10 | 822,554 | 0.066% |
| Bacteria | 2 | 577,222 | 0.047% |
| No hit | 2,364 | 52,165,386 | 4.211% |

Non-metazoan total: 67 scaffolds, 8,827,212 bp (0.713% of the assembly).

**Database used:** UniProt Swiss-Prot (575,503 proteins), not the full
UniProt Reference Proteomes (318 GB as of the 2026_02 release — a multi-day
run).

### 6. Contact-map figure (`plot_contact_map.py`)

PretextSnapshot's raster has no axes, tick labels, or colour legend.
[`plot_contact_map.py`](scripts/plot_contact_map.py) rebuilds the map from
`mapped.pairs` at 1 Mb resolution with labelled scaffolds, boundary
gridlines, and a log-scale colourbar (sequential single-hue — contact count
is a magnitude, not a category).

```bash
python scripts/plot_contact_map.py chrom_sizes.tsv contact_matrix_1mb.tsv out/contact_map
```

`chrom_sizes.tsv` (scaffold name, length) and `contact_matrix_1mb.tsv` (bin
i, bin j, contact count) are built from `mapped.pairs` by binning read pairs
into 1 Mb windows per scaffold pair. The colour scale floors at the
inter-scaffold (*trans*) contact median rather than 1, otherwise the trans
background alone saturates the ramp. See
[`../07_figures/README.md`](../07_figures/README.md) for where this fits
among the manuscript's figures.

## Software

| Tool | Version | Step |
|:--|:--|:--|
| bwa | 0.7.18-r1243 | Omni-C mapping (`-5SP -T0`); plain mapping for heterozygosity |
| samtools | 1.21 | sorting / indexing |
| pairtools | 1.1.0 | pair parsing, dedup (`--min-mapq 40 --walks-policy 5unique`) |
| PretextMap / PretextSnapshot | 0.1.9 / 0.0.4 | contact map |
| meryl | 1.4.1 | k-mer counting, k=21 |
| merqury | 1.3 | QV, k-mer completeness |
| genomescope2 | 2.0 | genome size, heterozygosity (ploidy=2) |
| r-base | 4.2.3 | GenomeScope dependency |
| minimap2 | 2.31-r1302 | PacBio coverage track (`-ax map-pb`) |
| diamond | 2.2.5 | blastx (`--sensitive --evalue 1e-25 --max-target-seqs 25`) |
| blobtoolkit | 4.5.5 | contamination screen (`--taxrule bestsumorder`) |
| bcftools | 1.21 | variant calling (heterozygosity, individual-identity check) |

See [`environment_qc.yml`](environment_qc.yml) — kept separate from the
top-level [`../environment.yml`](../environment.yml) because several of these
packages have conflicting pins (see the file), so they were installed into
isolated conda environments.

## Files

- [`scripts/hic_contact_map.sh`](scripts/hic_contact_map.sh) — Omni-C mapping and contact map
- [`scripts/kmer_genomescope.sh`](scripts/kmer_genomescope.sh) — meryl + GenomeScope2, any read set
- [`scripts/merqury_qv.sh`](scripts/merqury_qv.sh) — QV and k-mer completeness
- [`scripts/heterozygosity_omnic.sh`](scripts/heterozygosity_omnic.sh) — same-animal heterozygosity by remapping
- [`scripts/contamination_screen.sh`](scripts/contamination_screen.sh) — corrected DIAMOND + BlobToolKit screen
- [`scripts/plot_contact_map.py`](scripts/plot_contact_map.py) — labelled contact-map figure
- [`environment_qc.yml`](environment_qc.yml) — conda environment(s) for this section
