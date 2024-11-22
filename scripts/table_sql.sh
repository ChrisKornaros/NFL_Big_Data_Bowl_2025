#!/bin/zsh

# Set home variable and check PWD
home="/Users/chriskornaros/Documents/NFL_Big_Data_Bowl_2025"

if [[ echo $(pwd) != "$home" ]]; then
    cd "$home"
fi

# Loop through the scripts/files/tables.csv, for each table_name, write the sql into scripts/ddl/{table_name}_source.sql
