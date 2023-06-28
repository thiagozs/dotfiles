#!/bin/bash

# Update package lists
sudo apt-get update

# Check if Zsh is installed, and if not, install it
if ! command -v zsh &> /dev/null
then
    echo "Zsh is not installed. Installing..."
    sudo apt-get install -y zsh
else
    echo "Zsh is already installed."
fi

# Check if Oh-My-Zsh is installed, and if not, install it
if [ ! -d "$HOME/.oh-my-zsh" ] 
then
    echo "Oh-My-Zsh is not installed. Installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh-My-Zsh is already installed."
fi

# Check if the plugins are in the .zshrc file, and if not, add them
if ! grep -q 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' ~/.zshrc
then
    echo "Adding plugins to .zshrc..."
    echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" >> ~/.zshrc
    echo "Plugins added."
else
    echo "Plugins are already in .zshrc."
fi

# Source .zshrc to apply changes immediately
source ~/.zshrc

echo "Setup complete of zsh."