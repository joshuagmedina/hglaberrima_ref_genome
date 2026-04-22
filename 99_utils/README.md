# 99 — Utilities

Small helpers that are reused across the pipeline.

| Script                                 | Purpose                                                                |
|----------------------------------------|------------------------------------------------------------------------|
| [`seq_length.py`](seq_length.py)       | Print the length of one record in a FASTA (`--id`)                     |
| [`scaffold_lengths.py`](scaffold_lengths.py) | Per-record lengths + total genome length                           |
| [`sort_fasta.py`](sort_fasta.py)       | Sort a FASTA by sequence length (descending)                           |
| [`split_fasta.py`](split_fasta.py)     | Split after the first *N* records (used to separate 23 chromosomes)    |

All require Biopython (`pip install biopython`).
