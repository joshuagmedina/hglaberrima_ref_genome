#!/bin/bash

# Prompt for input files
echo "Enter the path to the IDs list file (ids_list.txt):"
read ids_file

echo "Enter the path to the sequences file (sequences.fa):"
read sequences_file

# Check if input files exist
if [ ! -f "$ids_file" ]; then
    echo "Error: IDs list file '$ids_file' not found."
    exit 1
fi

if [ ! -f "$sequences_file" ]; then
    echo "Error: Sequences file '$sequences_file' not found."
    exit 1
fi

# Derive base names for output files
ids_base=$(basename "$ids_file" .txt)
sequences_base=$(basename "$sequences_file" .fa)

# Define output file
output_file="${ids_base}.${sequences_base}.seqs.fa"

# Perform the AWK operation
awk -F'>' 'NR==FNR{ids[$0]; next} NF>1{split($2, headerParts, " "); f=(headerParts[1] in ids)} f' "$ids_file" "$sequences_file" > "$output_file"

echo "Filtered sequences saved in $output_file:"
grep ">" "$output_file" | head

