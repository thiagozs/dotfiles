#!/bin/bash

FONT_DIR="$HOME/.fonts"
FONT_AWESOME_DIR="$FONT_DIR/FontAwesome"

# Check if Font Awesome is installed
if [ -d "$FONT_AWESOME_DIR" ]; then
    echo "Font Awesome is already installed."
else
    echo "Font Awesome is not installed. Installing..."

    # Clone the Font Awesome GitHub repository
    git clone https://github.com/FortAwesome/Font-Awesome.git "$FONT_AWESOME_DIR"

    # Copy the fonts to the user's fonts directory
    cp "$FONT_AWESOME_DIR/otfs/"*.otf "$FONT_DIR"

    # Update the font cache
    fc-cache -f -v

    echo "Font Awesome has been installed."
fi
