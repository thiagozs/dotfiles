#!/bin/bash

# Change USERNAME to the username you wish to add to sudoers
# Check if the user exists, brew and docker is installed, and if not, install it
scripts/install_essentials.sh $1

# Check if Homebrew is installed, and if not, install it
scripts/install_brewpackages.sh

# Check if zsh is installed, and if not, install it
scripts/install_zsh.sh

# Check if zsh plugins are installed, and if not, install them
scripts/install_zsh_plugins.sh

# Register the functions helpers and aliases
tools/register_help_funcs.sh

# Register the paths for the scripts and apps
tools/register_help_paths.sh

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