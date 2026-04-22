import pandas as pd

# Load the BED file into a DataFrame
bed_file_path = 'Hglab.final.bed'
bed_df = pd.read_csv(bed_file_path, sep='\t', header=None, names=['chrom', 'start', 'end', 'name'])

# Filter rows where the chromosome is in the range Hglab_1 to Hglab_23
filtered_df = bed_df[bed_df['chrom'].str.match(r'Hglab_[1-9]$|Hglab_1[0-9]$|Hglab_2[0-3]$')]

# Remove the "Hglab_" substring from the chromosome labels
filtered_df['chrom'] = filtered_df['chrom'].str.replace('Hglab_', 'chr')

# Save the result to a new BED file
output_file_path = 'Hglab.final.filtered.bed'
filtered_df.to_csv(output_file_path, sep='\t', header=False, index=False)

print(f"The filtered and modified BED file has been saved to {output_file_path}")
