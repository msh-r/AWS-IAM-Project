#!/bin/bash
#purpose : Automated user creation in the AWS
#How to: ./aws-iam-create-user.sh <entry file format .csv>
#Entry file column name: user, group, password



# Check if the correct number of arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 users.csv"
    exit 1
fi

# Check if the input file exists
if [ ! -f "$1" ]; then
    echo "Error: Input CSV file '$1' not found."
    exit 1
fi

#Checking if dos2unix is present
command -v dos2unix >/dev/null || {echo "dos2unix tool not found.Pleae install dos2unix tools before running the script."; exit 1; }

dos2unix $1

# Read the input CSV file line by line
while IFS=',;' read -r username group password || [ -n "$user"]; do
    if [$user != "user" ]; then
        # Check if username, group, and password are not empty
        if [ -z "$user" ] || [ -z "$group" ] || [ -z "$password" ]; then
            echo "Error: Invalid entry in CSV file. Skipping..."
            continue
        fi

        # Create IAM user
        aws iam create-user --user-name "$user" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "IAM user '$user' created successfully."

            # Add user to the specified group
            aws iam add-user-to-group --user-name "$user" --group-name "$group" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "IAM user '$user' added to group '$group' successfully."
            else
                echo "Error: Failed to add IAM user '$user' to group '$group'."
            fi

            # Set password for the user
            aws iam create-login-profile --user-name "$user" --password "$password" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "Password set successfully for IAM user '$user'."
            else
                echo "Error: Failed to set password for IAM user '$user'."
            fi
        else
            echo "Error: Failed to create IAM user '$user'."
        fi
    fi
done < "$1"
