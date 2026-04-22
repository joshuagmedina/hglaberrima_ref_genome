# 04 — Comparative genomics

## 4.1 OrthoFinder — orthology inference

OrthoFinder v2.5.4 was run against deuterostome proteomes (see the
manuscript species table). Single-copy orthogroups are the input to the
phylogeny shown in Figure 2; the full `Orthogroups.tsv` is used for
Venn diagrams and lineage-specific gene counts.

```bash
orthofinder -f proteomes/ -t 32 -a 8 -M msa -T iqtree -S diamond
```

Downstream analysis and figures are in:

- [`orthofinder/OrthoFinder_Results_Analysis.Rmd`](orthofinder/OrthoFinder_Results_Analysis.Rmd)
  — Venn diagrams, lineage-specific gene sets, enrichment summaries.
- [`orthofinder/orthofinder_data_analysis.ipynb`](orthofinder/orthofinder_data_analysis.ipynb)
  — Python/pandas counts, plotting.
- [`orthofinder/orthofinder_data_analysis_mmus_hsap.ipynb`](orthofinder/orthofinder_data_analysis_mmus_hsap.ipynb)
  — Mouse/human comparison (supplementary).

## 4.2 Macrosynteny

Chromosome-level synteny against the other available sea cucumber and
echinoderm assemblies was computed with
[macrosynR](https://github.com/rossolabscbl/macrosynteny) from
single-copy orthologs (OrthoFinder output). A preprocessing step keeps
only the 23 chromosome-scale scaffolds:

```bash
python macrosynteny/main_scaffolds_genes.py
Rscript -e 'rmarkdown::render("macrosynteny/macrosynR_Hglabv42023.Rmd")'
```

Plots produced by the Rmd are the source for Figure 2 and Supplementary
Figure S2.

## Files

- [`orthofinder/*.Rmd`](orthofinder) and `*.ipynb` — OrthoFinder post-analysis
- [`macrosynteny/main_scaffolds_genes.py`](macrosynteny/main_scaffolds_genes.py)
  — keep only `Hglab_1`…`Hglab_23`, rename to `chr1`…`chr23`.
- [`macrosynteny/macrosynR_Hglabv42023.Rmd`](macrosynteny/macrosynR_Hglabv42023.Rmd)
  — macrosynR plot generation.
