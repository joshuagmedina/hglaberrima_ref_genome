#!/usr/bin/env bash
# contamination_screen.sh — DIAMOND + BlobToolKit contamination screen
#
# Screens only the unplaced scaffolds, not the whole assembly: an initial
# whole-genome run with --max-target-seqs 1 mistyped several chromosomes as
# plant/bacterial contamination from a single spurious hit per scaffold.
# --max-target-seqs 25 gives BlobToolKit's bestsumorder rule enough hits per
# scaffold to aggregate correctly.
#
# Usage:
#   contamination_screen.sh <assembly.fa> <n_chromosome_scale_scaffolds> \
#       <pacbio_coverage.bam> <diamond.dmnd> <new_taxdump_dir> <outdir> [threads]
set -euo pipefail

ASM=${1:?usage: contamination_screen.sh <assembly.fa> <n_chrom_scaffolds> <cov.bam> <diamond.dmnd> <new_taxdump_dir> <outdir> [threads]}
NCHROM=${2:?missing n_chromosome_scale_scaffolds}
COV=${3:?missing coverage bam}
DB=${4:?missing diamond db}
TAXDUMP=${5:?missing new_taxdump dir — must be NCBI new_taxdump, not the classic taxdump}
OUT=${6:?missing outdir}
THREADS=${7:-22}
FAI=${ASM}.fai
mkdir -p "$OUT"; cd "$OUT"
[[ -f "$FAI" ]] || samtools faidx "$ASM"

# unplaced = everything except the N largest (chromosome-scale) scaffolds.
# No `head` here — it SIGPIPEs `sort` under pipefail; awk consumes all input instead.
awk '{print $1"\t"$2}' "$FAI" | sort -k2,2nr | awk -v n="$NCHROM" 'NR<=n{print $1}' | sort > chrom.ids
cut -f1 "$FAI" | sort > all.ids
comm -23 all.ids chrom.ids > unplaced.ids
echo ">> chromosome-scale: $(wc -l < chrom.ids)   unplaced: $(wc -l < unplaced.ids)"
awk 'NR==FNR{k[$1];next} ($1 in k){print $1"\t0\t"$2}' unplaced.ids "$FAI" > unplaced.bed
awk '{s+=$3} END{printf ">> unplaced span: %d bp (%.2f Mb)\n", s, s/1e6}' unplaced.bed
samtools faidx "$ASM" -r <(cut -f1 unplaced.bed) > unplaced.fasta
samtools faidx unplaced.fasta

echo ">> diamond blastx, --max-target-seqs 25"
# sseqid (9th column) is required internally by blobtools despite being
# absent from BlobToolKit's documented outfmt.
diamond blastx --query unplaced.fasta --db "$DB" \
  --outfmt 6 qseqid staxids bitscore qstart qend sstart send evalue sseqid \
  --sensitive --max-target-seqs 25 --evalue 1e-25 --threads "$THREADS" \
  > diamond_unplaced.hits
echo ">> hits: $(wc -l < diamond_unplaced.hits)  over $(cut -f1 diamond_unplaced.hits | sort -u | wc -l) scaffolds"

echo ">> subsetting coverage BAM to the unplaced set"
# Rebuilt through SAM text, not `samtools reheader` — reheader swaps header
# text without remapping tids and corrupts the BAM.
samtools view -h -@ "$THREADS" -L unplaced.bed "$COV" \
 | awk -v idf=unplaced.ids 'BEGIN{while((getline l < idf)>0) keep[l]=1}
     /^@SQ/{split($2,a,":"); if(!(a[2] in keep)) next}
     /^@/{print; next}
     {if($3 in keep) print}' \
 > cov_unplaced.sam
samtools view -b cov_unplaced.sam | samtools sort -@ "$THREADS" -o cov_unplaced.bam -
samtools index -c cov_unplaced.bam
rm -f cov_unplaced.sam

echo ">> blobtools create/view/filter"
rm -rf blobdir
blobtools create --fasta unplaced.fasta --cov cov_unplaced.bam \
  --hits diamond_unplaced.hits \
  --hits-cols qseqid,staxids,bitscore,qstart,qend,sstart,send,evalue,sseqid \
  --taxrule bestsumorder --taxdump "$TAXDUMP" blobdir
blobtools view --plot blobdir || echo "!! plot step failed (headless env?); blobdir is still usable"
blobtools filter --table table.tsv \
  --table-fields gc,length,cov_unplaced_cov,bestsumorder_phylum blobdir || true

echo ">> blobdir: $OUT/blobdir"
echo ">> per-scaffold table: $OUT/table.tsv"
