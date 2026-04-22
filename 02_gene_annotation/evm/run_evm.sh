#!/bin/bash
# EVM v2.1.0 — partition, run in parallel, recombine, convert to GFF3.
#
# Inputs (assemble before running):
#   inputs/gene_predictions.gff3      (BRAKER AUGUSTUS + GeneMark.hmm)
#   inputs/transdecoder.gff3          (OTHER_PREDICTION)
#   inputs/protein_alignments.gff3    (spur_miniprot + hleu_miniprot)
#   inputs/transcript_alignments.gff3 (PASA alignment assemblies)
#   ../weights.txt                    (evidence weights)

set -euo pipefail

GENOME=${1:?usage: run_evm.sh <genome.fa>}
WEIGHTS=../weights.txt
SEGMENT_SIZE=100000
OVERLAP=10000
THREADS=${2:-16}

# --- 1. Partition ----------------------------------------------------------
$EVM_HOME/EvmUtils/partition_EVM_inputs.pl \
    --genome "${GENOME}" \
    --gene_predictions       inputs/gene_predictions.gff3 \
    --protein_alignments     inputs/protein_alignments.gff3 \
    --transcript_alignments  inputs/transcript_alignments.gff3 \
    --other_predictions      inputs/transdecoder.gff3 \
    --segmentSize "${SEGMENT_SIZE}" \
    --overlapSize "${OVERLAP}" \
    --partition_listing partitions_list.out

# --- 2. Write per-partition commands ---------------------------------------
$EVM_HOME/EvmUtils/write_EVM_commands.pl \
    --genome "${GENOME}" \
    --weights "$(realpath ${WEIGHTS})" \
    --gene_predictions       inputs/gene_predictions.gff3 \
    --protein_alignments     inputs/protein_alignments.gff3 \
    --transcript_alignments  inputs/transcript_alignments.gff3 \
    --other_predictions      inputs/transdecoder.gff3 \
    --output_file_name evm.out \
    --partitions partitions_list.out > commands.list

# --- 3. Run partitions in parallel -----------------------------------------
cat commands.list | xargs -P "${THREADS}" -I{} bash -c '{}'

# --- 4. Recombine ----------------------------------------------------------
$EVM_HOME/EvmUtils/recombine_EVM_partial_outputs.pl \
    --partitions partitions_list.out \
    --output_file_name evm.out

# --- 5. Convert to GFF3 ----------------------------------------------------
$EVM_HOME/EvmUtils/convert_EVM_outputs_to_GFF3.pl \
    --partitions partitions_list.out \
    --output evm.out \
    --genome "${GENOME}"

# Concatenate per-scaffold GFF3s
find . -name "evm.out.gff3" -exec cat {} + > EVM.all.gff3
echo "Final EVM annotation: EVM.all.gff3"
