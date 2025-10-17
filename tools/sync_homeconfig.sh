#!/bin/bash

# Check if at least two arguments are passed
if [ "$#" -lt 2 ]; then
    echo "You must specify a destination directory and at least one source directory."
    exit 1
fi

# Get the absolute path to the destination directory
DEST_DIR=$(realpath "$1")

# Check if the destination directory exists, and if not, create it
if [ ! -d "$DEST_DIR" ]; then
    echo "Destination directory $DEST_DIR does not exist. Creating it..."
    mkdir -p "$DEST_DIR"
fi

# Remove the first argument from the arguments array
shift

# Sync each directory with the destination directory
for dir in "$@"; do
    # Get the base name of the directory
    base_dir=$(basename "$dir")

    # Check if the directory exists
    if [ ! -d "$dir" ]; then
        echo "Directory $dir does not exist."
        continue
    fi

    # Sync the directory with the destination directory
    rsync -avh --progress "$dir/" "$DEST_DIR/$base_dir"
done

echo "Sync complete."
