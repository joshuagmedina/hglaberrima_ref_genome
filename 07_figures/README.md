# 07 — Figures

R Markdown notebooks that generate the publication figures from the
outputs of the earlier sections.

| Figure        | Source                                                                              |
|---------------|-------------------------------------------------------------------------------------|
| Figure 1 — Genome overview / circos | [`circos_plot_genome.Rmd`](circos_plot_genome.Rmd)                |
| Figure 1C — Hox9 scaffold alignment | [`nucmer-scaffold-alignment-plot.Rmd`](nucmer-scaffold-alignment-plot.Rmd) |
| Figure 2 — Macrosynteny             | [`../04_comparative_genomics/macrosynteny/macrosynR_Hglabv42023.Rmd`](../04_comparative_genomics/macrosynteny/macrosynR_Hglabv42023.Rmd) |
| Figure 3 — THAP TF phylogeny         | [`../05_gene_families/thap_crepe/CREPE_Data_Processing.Rmd`](../05_gene_families/thap_crepe/CREPE_Data_Processing.Rmd) + IQ-TREE/FigTree |
| Figure 4 — TE–gene proximity         | [`../06_transposons/TEclosest_genes.Rmd`](../06_transposons/TEclosest_genes.Rmd) |

## Rendering

```bash
Rscript -e 'rmarkdown::render("07_figures/circos_plot_genome.Rmd")'
Rscript -e 'rmarkdown::render("07_figures/nucmer-scaffold-alignment-plot.Rmd")'
```

R packages: `circlize`, `ggplot2`, `tidyverse`, `rtracklayer`,
`Biostrings`. Install from Bioconductor / CRAN as needed.
