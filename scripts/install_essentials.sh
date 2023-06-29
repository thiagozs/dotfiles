#!/bin/bash

# Change USERNAME to the username you wish to add to sudoers
USERNAME="$1"

# Check if the user exists
if id "$USERNAME" &>/dev/null; then

    # Check if the user already has sudo privileges
    if sudo -l -U "$USERNAME" | grep -q "(ALL : ALL) NOPASSWD: ALL"; then
        echo "The user $USERNAME already has sudo privileges without a password."
    else
        echo "Adding $USERNAME to sudoers..."
        echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo
        echo "$USERNAME has been added to sudoers and does not require a password to execute sudo commands."
    fi

else
    echo "The user $USERNAME does not exist."
fi


# Update package lists
sudo apt update

# Check if Homebrew is installed, and if not, install it
if ! command -v brew &> /dev/null
then
    echo "Homebrew is not installed. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Check if Docker is installed, and if not, install it
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Installing..."
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install -y docker-ce
else
    echo "Docker is already installed."
fi

echo "Setup complete of essentials."
