#!/bin/bash

# Check if the file paths/dotfiles.path contains the text "export"
if ! grep -q "export" paths/dotfiles.path; then
    # Check if we're in a directory named "dotfiles"
    if [[ "$(basename $(pwd))" == "dotfiles" ]]; then
        DOTFILES_PATH="$(pwd)"

        # Check if the path is not already in the PATH variable
        if [[ ":$PATH:" != *":$DOTFILES_PATH:"* ]]; then
            echo "export PATH=\$PATH:$DOTFILES_PATH" >> paths/dotfiles.path
            echo "export DOTFILES_PATH=$DOTFILES_PATH" >> paths/dotfiles.path
            echo "dotfiles directory added to PATH permanently."
        else
            echo "dotfiles directory is already in PATH."
        fi
    else
        echo "You are not in a dotfiles directory."
    fi
else 
    echo "The file paths/dotfiles.path already contains export statements. Skip..."
fi