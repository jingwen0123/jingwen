#!/bin/bash

# Check if exactly one argument (the filename) is provided;
# if not, print usage instructions and exit.
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 filename"
  exit 1
fi

# Store the input filename for later use in processing.
file="$1"

# Read the header line (first row) of the file and remove carriage return characters
# to avoid parsing issues across different operating systems.
header=$(head -n 1 "$file" | tr -d '\r')

# Split the header string into an array of column names using semicolon as delimiter.
# This enables accessing individual column names in a loop.
IFS=';' read -r -a columns <<< "$header"

# Get the total number of columns, so we know how many iterations the loop should run.
num_cols=${#columns[@]}

# Loop through each column index (1-based for 'cut' command).
for ((i=1; i<=num_cols; i++)); do
  # Retrieve the actual column name from the array for display.
  colname="${columns[$((i - 1))]}"

  # Count how many rows in this column are empty (blank or only whitespace).
  # Steps:
  # - Use 'cut' to extract the i-th column.
  # - Skip the first row (header) using 'tail'.
  # - Filter out rows that are completely blank using 'grep'.
  # - Count the remaining matches using 'wc -l'.
  count=$(cut -d';' -f"$i" "$file" \
          | tail -n +2 \
          | grep -E '^[[:space:]]*$' \
          | wc -l)

  # Output the column name along with the number of empty cells found.
  echo "$colname: $count"
done
