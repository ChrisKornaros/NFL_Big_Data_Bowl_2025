#!/bin/zsh

# Set home variable and define paths
home="/Users/chriskornaros/Documents/NFL_Big_Data_Bowl_2025"
input_csv="scripts/files/tables.csv"
output_dir="scripts/ddl"

# Check the working directory
if [[ pwd != "$home" ]]; then
    cd "$home"
fi

# Loop through each line in the CSV file
while IFS=, read -r table_name sql
do
  # Skip the header line
  if [[ $table_name == "table_name" ]]; then
    continue
  fi

  # Remove the surrounding quotes
  sql=${sql#\"}
  sql=${sql%\"}

  # Format the SQL into multiline
  # Not working, need to come back to this later
  #table_name_line=$(echo "$sql" | sed -n 's/CREATE TABLE \([^ ]\+\)(.*/CREATE TABLE \1(/p')
  #columns=$(echo "$sql" | sed -n 's/CREATE TABLE [^ ]\+(\(.*\));/\1/p' | tr ',' '\n' | sed '1!s/^/,/')

  formatted_sql="$table_name_line\n$columns\n);"
  
  # Define the output file
  output_file="$output_dir/${table_name}_source.sql"
  
  # Write the SQL to the output file
  echo "$sql" > "$output_file"

done < $input_csv

echo "DDL files generated in $output_dir"
