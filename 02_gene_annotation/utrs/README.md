# UTR prediction

Two independent sources of UTR evidence are used, then merged:

1. **GUSHR** (shipped with BRAKER v3.0.7) — runs as part of `braker.pl
   --UTR=on --addUTR=on`. Output: `augustus.hints_utr.gff`.
2. **stringtie2utr.py** — post-hoc UTR inference from a Stringtie
   transcript assembly against the BRAKER CDS annotation. The canonical
   upstream implementation is used:
   <https://github.com/stringtie/stringtie2utr.py>

After both sources are merged, fragmented 5′/3′ UTR entries are
consolidated to single spans per transcript/strand with
[`../scripts/consolidate_utrs.pl`](../scripts/consolidate_utrs.pl).

Command sketch (invoke exactly as in the Methods):

```bash
# 1. GUSHR is executed automatically by BRAKER3.
# 2. Independent stringtie-based UTRs:
python stringtie2utr.py \
    --gff  braker.gff3 \
    --stringtie stringtie_merged.gtf \
    --out  stringtie2utr.gff3

# 3. Consolidate fragmented UTR records from the combined GTF
perl ../scripts/consolidate_utrs.pl augustus_hints_with_utr.gtf \
    > augustus_hints_with_utr.consolidated.gtf
```
