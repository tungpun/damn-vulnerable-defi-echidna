#!/bin/bash

# Check if arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 [enable|disable] [directory]"
    exit 1
fi

ACTION=$1
DIRECTORY=$2

if [ "$ACTION" = "disable" ]; then
    # Find all files ending with .forge.sol and rename them to .forge.sol.disabled
    find "$DIRECTORY" -type f -name "*.forge.sol" | while read -r file; do
        echo "Disabling: $file"
        mv "$file" "${file}.disabled"
    done
    echo "All .forge.sol files have been disabled in $DIRECTORY"
elif [ "$ACTION" = "enable" ]; then
    # Find all files ending with .forge.sol.disabled and rename them back to .forge.sol
    find "$DIRECTORY" -type f -name "*.forge.sol.disabled" | while read -r file; do
        echo "Enabling: $file"
        mv "$file" "${file%.disabled}"
    done
    echo "All .forge.sol files have been enabled in $DIRECTORY"
else
    echo "Invalid action. Use 'enable' or 'disable'"
    exit 1
fi 
