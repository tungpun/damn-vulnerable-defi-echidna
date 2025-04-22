#!/bin/bash

# Check if an argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 [enable|disable]"
    exit 1
fi

ACTION=$1

if [ "$ACTION" = "disable" ]; then
    # Find all files ending with .forge.sol and rename them to .forge.sol.disabled
    find . -type f -name "*.forge.sol" | while read -r file; do
        echo "Disabling: $file"
        mv "$file" "${file}.disabled"
    done
    echo "All .forge.sol files have been disabled"
elif [ "$ACTION" = "enable" ]; then
    # Find all files ending with .forge.sol.disabled and rename them back to .forge.sol
    find . -type f -name "*.forge.sol.disabled" | while read -r file; do
        echo "Enabling: $file"
        mv "$file" "${file%.disabled}"
    done
    echo "All .forge.sol files have been enabled"
else
    echo "Invalid action. Use 'enable' or 'disable'"
    exit 1
fi 
