

---

# README – Board Game Dataset Scripts

This project includes three Bash scripts used to process and analyze a board game dataset. The workflow goes from identifying missing data, cleaning the file, and then performing basic statistical analysis.

---

## 1. Script: `empty_cells.sh`

**Purpose:**
Counts the number of empty or whitespace-only cells in each column of the raw dataset.

**Input:**
A raw file (`;`-delimited) with a header row.

**How to Use:**

```bash
./empty_cells.sh raw_file.txt
```

**What It Does:**

* Parses the header to identify all columns.
* Checks each column for empty cells.
* Outputs the count of empty entries for each column.

**Sample Output:**

```
/ID: 16
Name: 0
Year Published: 1
Min Players: 0
Max Players: 0
Play Time: 0
Min Age: 0
Users Rated: 0
Rating Average: 0
BGG Rank: 0
Complexity Average: 0
Owned Users: 23
Mechanics: 1598
Domains: 10159
...
```

---

## 2. Script: `preprocess.sh`

**Purpose:**
Cleans the raw data and converts it into a tab-separated format suitable for analysis.

**Main Features:**

* Fills in missing IDs with new sequential numbers.
* Replaces European-style decimal commas with dots.
* Removes control and non-ASCII characters.
* Converts the file to tab-separated values (TSV).
* Writes a clean output file: `bgg_dataset.tsv`

**How to Use:**

```bash
./preprocess.sh raw_file.txt
```

**Output:**
Preprocessing complete. Output saved to bgg_dataset.tsv

---

## 3. Script: `analysis.sh`

**Purpose:**
Performs key statistical analysis on the cleaned dataset.

**What It Calculates:**

* The most frequently used game mechanic.
* The most common game domain.
* The Pearson correlation between:

  * Year Published and Rating Average
  * Complexity Average and Rating Average

**How to Use:**

```bash
./analysis.sh bgg_dataset.tsv
```

**Sample Output:**

```
The most popular game mechanic is Dice Rolling found in 2185 games
The most popular game domain is Dice Rolling found in 2185 games
The correlation between the year of publication and the average rating is 1
The correlation between the complexity of a game and its average rating is 1
```

---

## Workflow Summary

1. Detect missing values:

   ```bash
   ./empty_cells.sh raw_file.csv
   ```

2. Clean and convert data:

   ```bash
   ./preprocess.sh raw_file.csv
   ```

3. Run analysis:

   ```bash
   ./analysis.sh bgg_dataset.tsv
   ```

---

## Requirements

These scripts use standard UNIX utilities:

* `awk`
* `cut`
* `grep`
* `sed`
* `sort`
* `uniq`
* `wc`

Tested on Ubuntu Linux and Docker containers.

---

## Author & Notes

This script collection was developed for the **CITS4407 - Open Source Tools and Scripting** course.
Temporary files generated during analysis (e.g., `_mech_freq.txt`, `_domain_freq.txt`) are automatically deleted after script execution.

