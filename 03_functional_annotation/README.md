# 03 — Functional annotation (UniProt BLAST + header rewriting)

After the EVM-consolidated gene set is finalized, each predicted protein
is BLASTed against UniProt (SwissProt + TrEMBL) and the best hit is used
to (a) rename the protein and transcript IDs in the FASTA headers and
(b) inject `Note=` / `product=` attributes into the GFF3.

## Pipeline

1. **Clean BRAKER/EVM protein FASTA** — strip everything after the first
   space in each header and drop sequences shorter than 20 aa
   (manuscript threshold).

    ```bash
    # Optional: identify sequences shorter than 20 aa for manual inspection
    perl scripts/extract_short_sequences.pl evm.proteins.fa > short_seqs.fa

    python scripts/modify_fasta_headers.py \
        --in  evm.proteins.fa \
        --out evm.proteins.clean.fa
    ```

2. **BLASTp against UniProt** — SwissProt first, then TrEMBL for
   everything that did not get a high-confidence SwissProt hit.

    ```bash
    makeblastdb -in uniprot_sprot.fasta -dbtype prot -out db/uniprot_sprot
    bash scripts/blastp_uniprot.sh evm.proteins.clean.fa db/uniprot_sprot \
        evm.vs.sprot.out
    ```

3. **Parse UniProt metadata** into a mapping TSV
   (qseqid → uniprot_id, gene, organism, product):

    ```bash
    python scripts/parse_uniprot_fasta.py \
        --blast evm.vs.sprot.out \
        --uniprot uniprot_sprot.fasta \
        --out uniprot_mapping.tsv
    ```

4. **Rewrite headers + GFF attributes** using the mapping:

    ```bash
    python scripts/apply_uniprot_annotation.py \
        --fasta evm.proteins.clean.fa \
        --gff   evm.gff3 \
        --map   uniprot_mapping.tsv \
        --out-fasta evm.proteins.annotated.fa \
        --out-gff   evm.annotated.gff3
    ```

## Files

- [`scripts/blastp_uniprot.sh`](scripts/blastp_uniprot.sh) — BLASTp wrapper (outfmt 6 + stitle).
- [`scripts/modify_fasta_headers.py`](scripts/modify_fasta_headers.py) — BRAKER/EVM header cleanup.
- [`scripts/parse_uniprot_fasta.py`](scripts/parse_uniprot_fasta.py) — extract mapping TSV.
- [`scripts/apply_uniprot_annotation.py`](scripts/apply_uniprot_annotation.py) — apply annotation to FASTA + GFF.
- [`scripts/extract_short_sequences.pl`](scripts/extract_short_sequences.pl) — report proteins < 20 aa.
