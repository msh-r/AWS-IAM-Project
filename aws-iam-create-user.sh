#!/bin/bash
# Purpose: Automated user creation in AWS
# How to: ./aws-iam-create-user.sh <entry_file.csv>
# Entry file column names: user, group, password
# ------------------------------------------

# Check if dos2unix is installed
command -v dos2unix >/dev/null || { echo "Error: dos2unix tool not found. Please install dos2unix before running the script."; exit 1; }


# Check if input file provided
[ $# -ne 1 ] && { echo "Usage: $0 users.csv"; exit 1; }

INPUT="$1"

# Check if input file exists
[ ! -f "$INPUT" ] && { echo "Error: $INPUT file not found."; exit 1; }

# Convert input file to Unix format
dos2unix "$INPUT"

# Read CSV file, create users, and assign them to groups
# Reads from second line "tail -n +2 "$input"

tail -n +2 "$INPUT" | while IFS=',;' read -r user group password; 

do

# Check if username, group, and password are not empty
    if [ -z "$user" ] || [ -z "$group" ] || [ -z "$password" ]; then
        echo "Error: Invalid entry in CSV file. Skipping..."
        continue
    fi

# Check if the user already exists
    aws iam get-user --user-name "$user" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "IAM user "$user" already exists. Skipping..."
        continue
    fi

#If all condition checks then we create the user
    aws iam create-user --user-name "$user"
    aws iam create-login-profile --password-reset-required --user-name "$user" --password "$password"
    aws iam add-user-to-group --group-name "$group" --user-name "$user"

done


echo "User creation completed."
