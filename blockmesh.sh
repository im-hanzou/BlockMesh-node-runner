#!/bin/bash

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No color (reset color)

# Check if curl is installed, and install if not
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi
sleep 1

# Check if bc is installed, and install if not
echo -e "${BLUE}Checking your OS version...${NC}"
if ! command -v bc &> /dev/null; then
    sudo apt update
    sudo apt install bc -y
fi
sleep 1

# Check Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)
REQUIRED_VERSION=22.04

if (( $(echo "$UBUNTU_VERSION < $REQUIRED_VERSION" | bc -l) )); then
    echo -e "${RED}This node requires at least Ubuntu 22.04${NC}"
    exit 1
fi

# Menu
echo -e "${YELLOW}Select an action:${NC}"
echo -e "${CYAN}1) Install Node${NC}"
echo -e "${CYAN}2) Check Logs (exit logs with CTRL+C)${NC}"
echo -e "${CYAN}3) Update Node${NC}"
echo -e "${CYAN}4) Restart Node${NC}"
echo -e "${CYAN}5) Remove Node${NC}"

echo -e "${YELLOW}Enter your choice:${NC} "
read choice

case $choice in
    1)
        echo -e "${BLUE}Installing BlockMesh Node...${NC}"

        # Check if tar is installed, and install if not
        if ! command -v tar &> /dev/null; then
            sudo apt install tar -y
        fi
        sleep 1
        
        # Download BlockMesh binary
        wget https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.364/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz

        # Extract the archive
        tar -xzvf blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz
        sleep 1

        # Remove the archive
        rm blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz

        # Navigate to the folder
        cd target/x86_64-unknown-linux-gnu/release/

        # Request user input
        echo -e "${YELLOW}Enter your BlockMesh email:${NC} "
        read EMAIL
        echo -e "${YELLOW}Enter your BlockMesh password:${NC} "
        read PASSWORD

        # Get the current username and home directory
        USERNAME=$(whoami)
        HOME_DIR=$(eval echo ~$USERNAME)

        # Create or update the service file
        sudo bash -c "cat <<EOT > /etc/systemd/system/blockmesh.service
[Unit]
Description=BlockMesh CLI Service
After=network.target

[Service]
User=$USERNAME
ExecStart=$HOME_DIR/target/x86_64-unknown-linux-gnu/release/blockmesh-cli login --email $EMAIL --password $PASSWORD
WorkingDirectory=$HOME_DIR/target/x86_64-unknown-linux-gnu/release
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT"

        # Reload systemd services and enable BlockMesh
        sudo systemctl daemon-reload
        sleep 1
        sudo systemctl enable blockmesh
        sudo systemctl start blockmesh

        # Final output
        echo -e "${GREEN}Installation complete and node started!${NC}"

        # Final message
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}Command to check logs:${NC}" 
        echo "sudo journalctl -u blockmesh -f"
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        sleep 2

        # Check logs
        sudo journalctl -u blockmesh -f
        ;;

    2)
        # Check logs
        sudo journalctl -u blockmesh -f
        ;;

    3)
        echo -e "${BLUE}Updating BlockMesh Node...${NC}"

        # Stop the service
        sudo systemctl stop blockmesh
        sudo systemctl disable blockmesh
        sudo rm /etc/systemd/system/blockmesh.service
        sudo systemctl daemon-reload
        sleep 1

        # Remove old node files
        rm -rf target
        sleep 1

        # Download the new BlockMesh binary
        wget https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.339/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz

        # Extract the archive
        tar -xzvf blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz
        sleep 1

        # Remove the archive
        rm blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz

        # Navigate to the folder
        cd target/x86_64-unknown-linux-gnu/release/

        # Request user input for update
        echo -e "${YELLOW}Enter your BlockMesh email:${NC} "
        read EMAIL
        echo -e "${YELLOW}Enter your BlockMesh password:${NC} "
        read PASSWORD

        # Get the current username and home directory
        USERNAME=$(whoami)
        HOME_DIR=$(eval echo ~$USERNAME)

        # Create or update the service file
        sudo bash -c "cat <<EOT > /etc/systemd/system/blockmesh.service
[Unit]
Description=BlockMesh CLI Service
After=network.target

[Service]
User=$USERNAME
ExecStart=$HOME_DIR/target/x86_64-unknown-linux-gnu/release/blockmesh-cli login --email $EMAIL --password $PASSWORD
WorkingDirectory=$HOME_DIR/target/x86_64-unknown-linux-gnu/release
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT"

        # Restart the service
        sudo systemctl daemon-reload
        sleep 1
        sudo systemctl enable blockmesh
        sudo systemctl restart blockmesh

        # Final output
        echo -e "${GREEN}Update complete and node restarted!${NC}"

        # Final message
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}Command to check logs:${NC}" 
        echo "sudo journalctl -u blockmesh -f"
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        sleep 2

        # Check logs
        sudo journalctl -u blockmesh -f
        ;;

    4)
        echo -e "${BLUE}Restarting BlockMesh Node...${NC}"

        # Stop the service
        sudo systemctl stop blockmesh

        # Navigate to the folder
        cd target/x86_64-unknown-linux-gnu/release/

        # Request user input
        echo -e "${YELLOW}Enter your BlockMesh email:${NC} "
        read EMAIL
        echo -e "${YELLOW}Enter your BlockMesh password:${NC} "
        read PASSWORD

        # Get the current username and home directory
        USERNAME=$(whoami)
        HOME_DIR=$(eval echo ~$USERNAME)

        # Update the service file
        sudo bash -c "cat <<EOT > /etc/systemd/system/blockmesh.service
[Unit]
Description=BlockMesh CLI Service
After=network.target

[Service]
User=$USERNAME
ExecStart=$HOME_DIR/target/x86_64-unknown-linux-gnu/release/blockmesh-cli login --email $EMAIL --password $PASSWORD
WorkingDirectory=$HOME_DIR/target/x86_64-unknown-linux-gnu/release
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT"

        # Restart the service with new credentials
        sudo systemctl daemon-reload
        sleep 1
        sudo systemctl restart blockmesh

        # Final output
        echo -e "${GREEN}Restart complete and node started with new credentials!${NC}"

        # Final message
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}Command to check logs:${NC}" 
        echo "sudo journalctl -u blockmesh -f"
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        sleep 2

        # Check logs
        sudo journalctl -u blockmesh -f
        ;;

    5)
        echo -e "${BLUE}Removing BlockMesh Node...${NC}"

        # Stop and disable the service
        sudo systemctl stop blockmesh
        sudo systemctl disable blockmesh

        # Remove the service file
        sudo rm /etc/systemd/system/blockmesh.service
        sudo systemctl daemon-reload

        # Remove BlockMesh files
        rm -rf target
        sleep 1

        echo -e "${GREEN}Node successfully removed!${NC}"
        ;;

    *)
        echo -e "${RED}Invalid choice, exiting...${NC}"
        ;;
esac
