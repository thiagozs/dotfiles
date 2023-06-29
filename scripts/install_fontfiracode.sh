#!/bin/bash

FONT_DIR="$HOME/.fonts"
FIRA_CODE_DIR="$FONT_DIR/FiraCode"

# Check if Fira Code is installed
if [ -d "$FIRA_CODE_DIR" ]; then
    echo "Fira Code is already installed."
else
    echo "Fira Code is not installed. Installing..."

    # Create the Fira Code directory if it doesn't exist
    mkdir -p "$FIRA_CODE_DIR"

    # Download the Fira Code font files
    wget -P "$FIRA_CODE_DIR" https://github.com/tonsky/FiraCode/releases/download/5.2/Fira_Code_v5.2.zip

    # Unzip the font files
    unzip "$FIRA_CODE_DIR/Fira_Code_v5.2.zip" -d "$FIRA_CODE_DIR"

    # Copy the font files to the user's fonts directory
    cp "$FIRA_CODE_DIR/ttf/"*.ttf "$FONT_DIR"

    # Remove the downloaded zip file
    rm "$FIRA_CODE_DIR/Fira_Code_v5.2.zip"

    # Update the font cache
    fc-cache -f -v

    echo "Fira Code has been installed."
fi
