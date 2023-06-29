#!/bin/bash

# Check if Slack is installed
if command -v slack >/dev/null 2>&1; then
    echo "Slack is already installed."
else
    echo "Slack is not installed. Installing..."

    # Download the latest Slack deb package
    wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb

    # Install the downloaded package
    sudo dpkg -i slack-desktop-4.0.2-amd64.deb

    # Fix any potential dependency issues
    sudo apt install -f

    # Remove the downloaded package
    rm slack-desktop-4.0.2-amd64.deb

    echo "Slack has been installed."
fi
