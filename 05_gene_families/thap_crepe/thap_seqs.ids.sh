#!/bin/bash

# Loop through each CSV file
for input_file in *.csv
do
    echo "Processing $input_file..."
    
    # Extract base name of input file without extension
    base_name=$(basename "$input_file" .csv)
    
    # Define output file with base name + _THAP.txt
    output_file="${base_name}_THAP.txt"

    # Step 1: Filter rows that contain "THAP" in the last column
    # Step 2: Remove "_CREPE" from the third column
    awk -F, '$NF ~ /THAP/ {gsub("_CREPE", "", $3); print $3}' "$input_file" | sed 's/^"\(.*\)"$/\1/' > ./01_THAPS_PER_SPECIES/"$output_file"
    
    echo "Filtered substrings saved in $output_file:"
    cat "$output_file"
done
