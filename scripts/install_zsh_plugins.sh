#!/bin/bash

# Check if zsh-autosuggestions is installed, and if not, install it
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ] 
then
    echo "zsh-autosuggestions is not installed. Installing..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    echo "zsh-autosuggestions is already installed."
fi

# Check if zsh-syntax-highlighting is installed, and if not, install it
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]
then
    echo "zsh-syntax-highlighting is not installed. Installing..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    echo "zsh-syntax-highlighting is already installed."
fi

ZSHRC="$HOME/.zshrc"
OLD_PLUGIN_LINE="plugins=(git)"
NEW_PLUGIN_LINE="plugins=(git zsh-autosuggestions zsh-syntax-highlighting)"

# Check if the old plugin line exists in .zshrc
if grep -Fxq "$OLD_PLUGIN_LINE" $ZSHRC
then
    # If it exists, replace it with the new plugin line
    sed -i "s/$OLD_PLUGIN_LINE/$NEW_PLUGIN_LINE/g" $ZSHRC
    echo "Updated .zshrc with new plugins."
else
    echo "The old plugin line does not exist in .zshrc."
fi

# Source .zshrc to apply changes immediately
source ~/.zshrc

echo "Setup complete of zsh_plugins."