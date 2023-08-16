#!/bin/bash

# Check if ZSH_CUSTOM is set
if [ -z "$ZSH_CUSTOM" ]; then
    echo "ZSH_CUSTOM is not set. Aborting..."
    exit 1
else
    echo "ZSH_CUSTOM is set to $ZSH_CUSTOM."
fi

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

# Specify the current theme line and the new theme line
OLD_THEME_LINE="ZSH_THEME=\"robbyrussell\""
NEW_THEME_LINE="ZSH_THEME=\"spaceship\""

# Check if Spaceship theme is installed, and if not, install it
if [ ! -d "$ZSH_CUSTOM/themes/spaceship-prompt" ] 
then
    echo "Spaceship theme is not installed. Installing..."
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1

    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
else
    echo "Spaceship theme is already installed."
fi

# Check if the Spaceship theme is set in the .zshrc file, and if not, set it
if grep -Fxq "$NEW_THEME_LINE" $ZSHRC
then
    echo "Spaceship theme is already set in .zshrc."
else
    # Replace the current theme with Spaceship
    sed -i "s/$OLD_THEME_LINE/$NEW_THEME_LINE/g" $ZSHRC
    echo "Spaceship theme has been set in .zshrc."
fi

echo "Setup complete of zsh_plugins."