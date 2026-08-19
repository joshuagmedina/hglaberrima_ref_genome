#!/usr/bin/env bash
# heterozygosity_omnic.sh — heterozygosity of the assembled individual
#
# Re-maps Omni-C reads single-end with plain bwa mem (no -5SP): the Hi-C BAM
# from hic_contact_map.sh carries hard-clipped supplementary records that
# bcftools mpileup silently skips, giving a bogus 0% heterozygosity.
#
# Usage:
#   heterozygosity_omnic.sh <assembly.fa> <R1.fastq.gz> <R2.fastq.gz> <outdir> <region> [threads] [n_pairs] [min_depth]
set -euo pipefail

ASM=${1:?usage: heterozygosity_omnic.sh <assembly.fa> <R1.fastq.gz> <R2.fastq.gz> <outdir> <region> [threads] [n_pairs] [min_depth]}
R1=${2:?missing R1}
R2=${3:?missing R2}
OUT=${4:?missing outdir}
REGION=${5:?missing region, e.g. Hglab_1}
THREADS=${6:-16}
PAIRS=${7:-60000000}
MINDP=${8:-10}
LINES=$((PAIRS * 4))
TMP="$OUT/tmp"
mkdir -p "$OUT" "$TMP"

echo ">> mapping ${PAIRS} reads/file single-end, plain bwa mem, region $REGION"
for R in R1 R2; do
  f=${!R}
  bwa mem -t "$THREADS" "$ASM" <(zcat "$f" | head -n "$LINES") \
   | samtools view -u -q 30 -F 2308 -e "(rname==\"$REGION\")" - \
   | samtools sort -@ 4 -T "$TMP/oh_$R" -o "$OUT/omnic_$R.bam"
done
samtools merge -f -@ 8 "$OUT/omnic.bam" "$OUT/omnic_R1.bam" "$OUT/omnic_R2.bam"
samtools index "$OUT/omnic.bam"

CALLABLE=$(samtools depth -a -q 20 -Q 30 -r "$REGION" "$OUT/omnic.bam" \
  | awk -v d="$MINDP" '$3>=d{n++} END{print n+0}')
echo ">> callable ($REGION, DP>=$MINDP): $CALLABLE"

echo ">> calling variants"
bcftools mpileup -f "$ASM" -r "$REGION" -q 30 -Q 20 -a AD,DP -Ou "$OUT/omnic.bam" \
 | bcftools call -mv -Oz -o "$OUT/omnic_het.vcf.gz"
bcftools index "$OUT/omnic_het.vcf.gz"

bcftools query -f '%TYPE\t[%GT]\t[%DP]\n' "$OUT/omnic_het.vcf.gz" \
 | awk -v mindp="$MINDP" -v callable="$CALLABLE" '
   $3>=mindp && $1=="SNP" {
     gt=$2; gsub("\\|","/",gt)
     if (gt=="0/1"||gt=="1/0") het++; else if (gt=="1/1") homalt++
   }
   END{
     printf "\n===== HETEROZYGOSITY (same individual as the assembly) =====\n"
     printf "callable bases (DP>=%d) : %d\n", mindp, callable
     printf "heterozygous SNPs       : %d\n", het
     printf "homozygous-ALT SNPs     : %d  (residual assembly error)\n", homalt
     if (callable>0){
       printf "heterozygosity          : %.4f%%\n", 100*het/callable
       printf "hom-alt rate            : %.4f%%\n", 100*homalt/callable
     }
     printf "==============================================================\n"
   }'
