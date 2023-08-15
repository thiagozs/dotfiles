#!/bin/bash

# get a root folder
root_dir=$(git rev-parse --show-toplevel)

# Directory containing your scripts
script_dir="${root_dir}/paths"

# Function to add source line to .zshrc if it doesn't exist
function add_source_if_not_exists() {
    # Check if file name is provided
    if [ -z "$1" ]; then
        echo "Please provide a file to source."
        return 1
    fi

    # Full path to the file
    file_path=$(realpath "$1")

    # Check if file exists
    if [ ! -f "$file_path" ]; then
        echo "File does not exist: $file_path"
        return 1
    fi

    # Check if .zshrc already contains the source line
    if grep -Fxq "source $file_path" ~/.zshrc; then
        echo ".zshrc already contains 'source $file_path'"
    else
        # Add source line to .zshrc
        echo "source $file_path" >> ~/.zshrc
        echo "Added 'source $file_path' to ~/.zshrc"
    fi
}

echo "Registering paths from folder: ${script_dir}"

# Register the functions from the scripts in the directory
for file in "${script_dir}"/*.path; do
    echo "Registering path from file: ${file}"
    add_source_if_not_exists "${file}"
done

# Print a message to let the user know the setup is complete
echo "Setup complete."
