#!/bin/bash

# get a root folder
root_dir=$(git rev-parse --show-toplevel)

# Ensure the .dotfiles directory exists
mkdir -p $HOME/.dotfiles/paths
mkdir -p $HOME/.dotfiles/aliases

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

script_dir="${root_dir}/paths"
echo "Registering functions from folder: ${script_dir}"

for file in "${script_dir}"/*.path; do
    # Copy the file to $HOME/.dotfiles/paths
    cp "$file" "$HOME/.dotfiles/paths/"
    echo "Registering path from file: ${file}"
    add_source_if_not_exists "$HOME/.dotfiles/paths/$(basename $file)"
done

script_dir="${root_dir}/aliases"
echo "Registering functions from folder: ${script_dir}"

for file in "${script_dir}"/*.aliases; do
    # Copy the file to $HOME/.dotfiles/aliases
    cp "$file" "$HOME/.dotfiles/aliases/"
    echo "Registering functions from file: ${file}"
    add_source_if_not_exists "$HOME/.dotfiles/aliases/$(basename $file)"
done

echo "Setup complete."
