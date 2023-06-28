#!/bin/bash

# Specify the filename
filename="brew_packages.txt"

# Export the list of installed packages
brew list > $filename

echo "The list of installed packages has been exported to $filename."