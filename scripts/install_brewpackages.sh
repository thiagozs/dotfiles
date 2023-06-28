#!/bin/bash

# Update package lists
sudo apt-get update

# Update Homebrew
brew update

# Upgrade packages
brew upgrade

# Specify the filename
filename="brew_packages.txt"

# Check if the file exists
if [ -f $filename ]; then
    while IFS= read -r package
    do
        if brew list --formula -1 | grep -q "^${package}\$"; then
            echo "$package is already installed."
        else
            echo "Installing $package..."
            brew install "$package" > /dev/null 2>&1
            echo "$package has been installed."
        fi
    done < $filename
    echo "All packages have been processed."
else
    echo "File $filename does not exist."
fi