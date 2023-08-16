#!/bin/bash

# Check if Visual Studio Code is installed
if command -v code >/dev/null 2>&1; then
    echo "Visual Studio Code is already installed."
else
    echo "Visual Studio Code is not installed. Installing..."

    # Import Microsoft's GPG key
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/

    # Enable the Visual Studio Code repository
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

    # Update package lists and install Visual Studio Code
    sudo apt update -y 
    sudo apt install -y code

    echo "Visual Studio Code has been installed."
fi
