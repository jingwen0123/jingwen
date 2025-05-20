#!/bin/bash

# Step 1: Ensure one input argument is provided
# Purpose: Avoid ambiguity or errors due to missing/multiple arguments
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 input_file"
  exit 1
fi

input_file="$1"
output_file="bgg_dataset.tsv"

# Step 2: Extract the highest numeric ID in the first column (after header)
# Why: For assigning new unique IDs to rows where the ID is missing
max_id=$(awk -F';' '
  NR > 1 && $1 ~ /^[0-9]+$/ && $1 > max { max = $1 }
  END { print max + 1 }
' "$input_file")

# Step 3: Manually write correct column headers to the output file
# Reason: Ensures downstream scripts can correctly identify column names
# NOTE: These must exactly match your dataset structure (adjust if needed)
cat <<EOF > "$output_file"
ID	Name	Year Published	Min Players	Max Players	Play Time	Min Age	Users Rated	Rating Average	Rank	Complexity Average	Owned Users	Mechanics	Domains
EOF

# Step 4: Clean and transform data, and append to output
awk -v max_id="$max_id" -F';' '
BEGIN {
  OFS = "\t"  # Output as tab-separated format (TSV)
}

NR == 1 { next }  # Skip the original header row in the input file

{
  if ($1 == "") $1 = max_id++  # Assign missing ID

  for (i = 1; i <= NF; i++) {
    gsub(",", ".", $i)              # Fix European-style decimal commas
    gsub(/[\x00-\x1F\x7F]/, "", $i) # Remove control/non-ASCII characters
  }

  print  # Output cleaned line
}
' "$input_file" | sed 's/\r$//' >> "$output_file"

# Step 5: Inform user of completion
echo "Preprocessing complete. Output saved to $output_file"
