#!/bin/bash

# Step 1: Validate input
# Purpose: The script expects exactly one cleaned TSV file to analyze
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 cleaned_file.tsv"
  exit 1
fi

file="$1"

# Step 2: Parse header and identify column indexes dynamically
# Reason: Avoid hard-coding column positions; supports flexible column ordering
header=$(head -n 1 "$file")
IFS=$'\t' read -r -a cols <<< "$header"

# Initialize column index variables
for i in "${!cols[@]}"; do
  col="${cols[$i]}"
  case "$col" in
    "Year Published") year_idx=$i ;;
    "Rating Average") rating_idx=$i ;;
    "Complexity Average") comp_idx=$i ;;
    "Mechanics") mech_idx=$i ;;
    "Domains") domain_idx=$i ;;
  esac
done

# Step 3: Identify most frequent game mechanic
# Reason: Understand which mechanic appears most commonly across games
cut -f $((mech_idx+1)) "$file" | tail -n +2 \
  | tr ',' '\n' | sed 's/^ *//;s/ *$//' | grep -v '^$' \
  | sort | uniq -c | sort -nr > _mech_freq.txt

top_mech=$(head -n 1 _mech_freq.txt | sed 's/^ *//')
top_mech_count=$(echo "$top_mech" | cut -d' ' -f1)
top_mech_name=$(echo "$top_mech" | cut -d' ' -f2-)

echo "The most popular game mechanic is $top_mech_name found in $top_mech_count games"

# Step 4: Identify most frequent game domain
# Logic: Same as above, but applied to the Domains column
cut -f $((domain_idx+1)) "$file" | tail -n +2 \
  | tr ',' '\n' | sed 's/^ *//;s/ *$//' | grep -v '^$' \
  | sort | uniq -c | sort -nr > _domain_freq.txt

top_domain=$(head -n 1 _domain_freq.txt | sed 's/^ *//')
top_domain_count=$(echo "$top_domain" | cut -d' ' -f1)
top_domain_name=$(echo "$top_domain" | cut -d' ' -f2-)

echo "The most popular game domain is $top_domain_name found in $top_domain_count games"

# Step 5: Calculate Pearson correlation between Year Published and Rating
# Reason: Determine whether newer games are rated higher or lower
awk -v y=$((year_idx+1)) -v r=$((rating_idx+1)) -F'\t' '
  NR > 1 && $y != "" && $r != "" {
    year = $y + 0; rating = $r + 0
    sum_x += year; sum_y += rating
    sum_xx += year * year
    sum_yy += rating * rating
    sum_xy += year * rating
    n++
  }
  END {
    if (n > 0) {
      num = n * sum_xy - sum_x * sum_y
      den = sqrt((n * sum_xx - sum_x^2) * (n * sum_yy - sum_y^2))
      corr = (den != 0) ? num / den : "undefined"
      printf "The correlation between the year of publication and the average rating is %s\n", corr
    }
  }
' "$file"

# Step 6: Calculate Pearson correlation between Complexity and Rating
# Reason: Investigate whether more complex games tend to receive higher or lower ratings
awk -v c=$((comp_idx+1)) -v r=$((rating_idx+1)) -F'\t' '
  NR > 1 && $c != "" && $r != "" {
    comp = $c + 0; rating = $r + 0
    sum_x += comp; sum_y += rating
    sum_xx += comp * comp
    sum_yy += rating * rating
    sum_xy += comp * rating
    n++
  }
  END {
    if (n > 0) {
      num = n * sum_xy - sum_x * sum_y
      den = sqrt((n * sum_xx - sum_x^2) * (n * sum_yy - sum_y^2))
      corr = (den != 0) ? num / den : "undefined"
      printf "The correlation between the complexity of a game and its average rating is %s\n", corr
    }
  }
' "$file"

# Step 7: Clean up temporary frequency files
rm -f _mech_freq.txt _domain_freq.txt
