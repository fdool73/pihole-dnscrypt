#!/bin/bash

# This script installs Docker, Docker Compose, Apache, PHP, and other requirements for pihole and dnscrypt.

# Get the current user
CURRENT_USER=$(whoami)

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
}

# Function to install Docker Compose
install_compose() {
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

# Function to install Apache and PHP
install_apache_php() {
    echo "Installing Apache..."
    sudo apt install apache2 -y
    
    # Navigate to Apache document root
    cd /var/www/html
    
    # List directory contents with details
    ls -al
    
    # Change ownership of index.html to the current user
    sudo chown "$CURRENT_USER:" index.html
    
    echo "Installing PHP and Apache PHP module..."
    sudo apt install php libapache2-mod-php -y
    
    # Remove existing index.html
    sudo rm index.html
    
    # Create index.php and add a PHP echo statement
    echo '<?php echo "scram"; ?>' | sudo tee index.php > /dev/null
    
    echo "Apache and PHP installation complete."
}

# Function to configure the firewall
configure_firewall() {
    echo "Configuring the firewall..."
    sudo ufw allow 53/tcp  # Allow DNS traffic over TCP
    sudo ufw allow 53/udp  # Allow DNS traffic over UDP
    sudo ufw allow 80/tcp  # Allow HTTP traffic
    sudo ufw allow 443/tcp # Allow HTTPS traffic
    
    # Get the IP address of the eth0 interface
    ETH0_IP=$(ip -4 addr show eth0 | grep inet | awk '{print $2}' | cut -d/ -f1)
    
    # Allow SSH traffic from the eth0 IP
    sudo ufw allow from "$ETH0_IP" to any port 22

    sudo ufw reload
}

# Function to add the current user to the Docker group
add_user_to_docker() {
    echo "Adding the current user to the Docker group..."
    sudo usermod -aG docker $CURRENT_USER
    echo "You may need to log out and log back in for the group changes to take effect."
}

# Main function to call all other functions
main() {
    install_docker
    install_compose
    install_apache_php
    configure_firewall
    add_user_to_docker
}

# Execute the main function
main

