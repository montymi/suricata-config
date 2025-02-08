#!/bin/bash

# Detect OS
OS="$(uname)"
SURICATA_CONFIG_URL="https://raw.githubusercontent.com/montymi/suricata-config/main/suricata.yaml"

install_suricata_debian() {
    # Update package list and install Suricata
    sudo apt-get update
    sudo apt-get install -y suricata
}

install_suricata_redhat() {
    # Install EPEL repository and Suricata using dnf
    sudo dnf install -y epel-release
    sudo dnf install -y suricata
}

install_suricata_mac() {
    # Install Homebrew if not installed, then install Suricata
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install suricata
}

install_suricata_windows() {
    # Download and install Suricata
    choco install suricata -y
}

configure_suricata() {
    # Download the Suricata configuration file
    sudo curl -o /etc/suricata/suricata.yaml $SURICATA_CONFIG_URL

    # Ensure the correct interface is set in the Suricata configuration
    if [[ "$OS" == "Darwin" ]]; then
        sudo sed -i '' 's/interface: .*/interface: en0/' /etc/suricata/suricata.yaml
    else
        sudo sed -i 's/interface: .*/interface: eth0/' /etc/suricata/suricata.yaml
    fi
}

start_suricata_unix() {
    sudo systemctl start suricata
    sudo systemctl enable suricata
}

start_suricata_windows() {
    sc start Suricata
}

if [[ "$OS" == "Linux" ]]; then
    if [ -f /etc/debian_version ]; then
        install_suricata_debian
    elif [ -f /etc/redhat-release ]; then
        install_suricata_redhat
    fi
    configure_suricata
    start_suricata_unix

elif [[ "$OS" == "Darwin" ]]; then
    install_suricata_mac
    configure_suricata
    start_suricata_unix

elif [[ "$OS" == "MINGW64_NT"* || "$OS" == "CYGWIN_NT"* ]]; then
    install_suricata_windows
    configure_suricata
    start_suricata_windows

else
    echo "Unsupported OS: $OS"
    exit 1
fi

echo "Suricata setup and network monitoring configuration completed."