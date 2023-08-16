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

# Register the dotfiles paths
tools/register_help_dotfiles.sh