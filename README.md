# *Holothuria glaberrima* reference genome — code repository

This repository contains the code and configuration used to produce the
chromosome-scale reference genome and annotation for the sea cucumber
*Holothuria glaberrima* described in:

> Medina-Feliciano JG et al. *A chromosome-scale reference genome for the
> sea cucumber* Holothuria glaberrima. (manuscript in preparation)

The goal of this repository is to make every computational step of the
manuscript reproducible. It is **not** a pipeline manager — each section
contains the exact commands, SLURM scripts, and helper scripts that were
run, with a short README explaining inputs, outputs, and software
versions.

## Data availability

All raw and processed data files referenced by these scripts are
deposited on FigShare:

- **FigShare DOI:** [10.6084/m9.figshare.31743223](https://doi.org/10.6084/m9.figshare.31743223)

The final assembly and annotation files are also available through NCBI
under BioProject PRJNA940062 (GenBank/RefSeq accessions listed in the
manuscript).

## Repository layout

```
hglaberrima_ref_genome/
├── 01_assembly_correction/    # Draft v2 → v4 correction: manual Hox9 curation,
│                              #   SSPACE mate-pair scaffolding, RagTag, validation
├── 02_gene_annotation/        # BRAKER3, TSEBRA, miniprot, PASA, EVM, UTR consolidation
├── 03_functional_annotation/  # UniProt BLASTp mapping, GFF/FASTA header rewriting
├── 04_comparative_genomics/   # OrthoFinder, macrosynR, chromosome-level synteny
├── 05_gene_families/          # Hox cluster verification, THAP TF cataloguing (CREPE)
├── 06_transposons/            # EDTA TE annotation, RepeatMasker, TE-proximal gene analysis
├── 07_figures/                # Main-text and supplementary figure scripts (circos, plots)
├── 99_utils/                  # Small FASTA/GFF helpers used across sections
├── environment.yml            # Global conda environment (minimap2, samtools, mummer, etc.)
└── README.md                  # (this file)
```

Each numbered folder has its own `README.md` with:

1. The manuscript paragraph it reproduces.
2. Software versions.
3. Input files (with FigShare paths) and expected outputs.
4. Exact run commands.

## Software versions

| Tool                   | Version   | Used for                                   |
|------------------------|-----------|--------------------------------------------|
| WTDBG2                 | n/a       | draft long-read assembly (Dovetail)        |
| HiRise (Dovetail)      | proprietary | Omni-C Hi-C scaffolding                  |
| SSPACE Standard        | v3.0      | artificial mate-pair scaffolding (Hox9 fix)|
| matemaker              | v1.2      | generate artificial mate pairs             |
| RagTag                 | ≥2.1      | reference-guided scaffolding               |
| mummer (nucmer/dnadiff)| v4.0.0    | assembly–draft alignment                   |
| minimap2               | v2.22     | long-read / cross-assembly alignment       |
| BUSCO                  | v5        | assembly/annotation completeness           |
| gVolante2              | web       | completeness reporting                     |
| RepeatModeler          | v2.0.5    | de novo repeat library                     |
| RepeatMasker           | v4.1.5    | repeat masking                             |
| EDTA                   | v2.1.1 / v2.2.1 | transposable element annotation      |
| STAR                   | latest    | RNA-seq alignment for BRAKER3              |
| BRAKER                 | v3.0.7    | gene prediction                            |
| GeneMark-ETP           | v1.02     | ab initio prediction inside BRAKER         |
| Augustus               | v3.5.0    | ab initio prediction inside BRAKER         |
| ProtHint               | v2.6.0    | protein-hint generation                    |
| TSEBRA                 | v1.1.2.2  | BRAKER run combination                     |
| miniprot               | v0.12     | cross-species protein alignment            |
| Stringtie              | v2.2.1    | transcript assembly                        |
| PASA                   | v2.5.3    | transcript-based annotation                |
| EVidenceModeler (EVM)  | v2.1.0    | evidence consolidation                     |
| GUSHR / stringtie2utr.py | latest  | 5′/3′ UTR addition                         |
| OrthoFinder            | v2.5.4    | orthology inference                        |
| macrosynR / circlize   | latest    | synteny plots                              |
| MAFFT                  | v7.480    | multiple sequence alignment                |
| IQ-TREE                | v2.3.2    | phylogenetic inference                     |
| FigTree                | v1.4      | tree visualization                         |
| CREPE                  | see repo  | THAP transcription factor cataloguing      |
| InterProScan           | ≥5.60     | functional domain annotation               |

See each section's README for the exact invocation.

## Contact

Joshua G. Medina-Feliciano — joshua.medina8@upr.edu
