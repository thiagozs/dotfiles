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
    export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
else
    echo "Homebrew is already installed."
fi

# Check if Docker is installed, and if not, install it
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing now..."

    # Update package database
    sudo apt-get update

    # Install pre-requisites
    sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common -y

    # Add Dockers official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Add Docker's stable repository
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"

    # Install Docker CE
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y

    # Add current user to docker group (to run Docker as a non-root user)
    sudo usermod -aG docker $USER

else
    echo "Docker is already installed."
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing now..."

    # Install docker-compose
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

else
    echo "Docker Compose is already installed."
fi

# Check if Docker Desktop is not installed
if ! dpkg -l | grep -q docker-desktop; then

    # Prerequisites
    echo "Installing prerequisites..."
    sudo apt install gnome-terminal wget

    # Download Docker Desktop .deb package
    echo "Downloading Docker Desktop..."
    wget https://desktop.docker.com/linux/main/amd64/docker-desktop-4.22.0-amd64.deb

    # Uninstall any tech preview or beta version of Docker Desktop for Linux
    echo "Uninstalling any previous versions of Docker Desktop..."
    sudo apt remove docker-desktop
    rm -r $HOME/.docker/desktop
    sudo rm /usr/local/bin/com.docker.cli
    sudo apt purge docker-desktop

    # Install Docker Desktop
    echo "Installing Docker Desktop..."

    # Update the system
    sudo apt-get update -y

    # Install the downloaded .deb package
    sudo apt-get install -y ./docker-desktop-4.22.0-amd64.deb

    # Launch Docker Desktop
    echo "Starting Docker Desktop..."
    systemctl --user start docker-desktop

    # Enable Docker Desktop to start on login
    echo "Enabling Docker Desktop to start on login..."
    systemctl --user enable docker-desktop

    rm -fr docker-desktop-4.22.0-amd64.deb

    echo "Docker Desktop installation completed!"

else
    echo "Docker Desktop is already installed."
fi



echo "Setup complete of essentials."
