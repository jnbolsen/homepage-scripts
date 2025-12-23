#!/bin/bash

set -e  # Exit on any error
set -u  # Exit on undefined variables
set -o pipefail  # Exit on pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
msg_info() {
    echo -e "${YELLOW}INFO:${NC} $1"
}

msg_ok() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

msg_error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Variables
APP="homepage"
LOCAL_IP=$(hostname -I | awk '{print $1}')
RELEASE=$(curl -fsSL "https://api.github.com/repos/gethomepage/homepage/releases/latest" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)
VERSION_FILE="/opt/${APP}_version"

# Validate release version
if [ -z "$RELEASE" ]; then
    msg_error "Could not fetch release version"
    exit 1
fi

# Validate LOCAL_IP
if [ -z "$LOCAL_IP" ]; then
    msg_error "Could not determine local IP address"
    exit 1
fi

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   msg_error "This script must be run as root"
   exit 1
fi

# Check if curl is installed
if ! command_exists curl; then
    msg_error "curl is required but not installed"
    exit 1
fi

# Check if npm is installed
if ! command_exists npm; then
    msg_error "npm is required but not installed"
    exit 1
fi

# Version check - If version file exists and matches current release, exit
if [ -f "$VERSION_FILE" ]; then
    INSTALLED_VERSION=$(cat "$VERSION_FILE")
    if [ "$INSTALLED_VERSION" = "$RELEASE" ]; then
        msg_ok "Latest version ${RELEASE} of ${APP} is already installed"
        exit 0
    fi
fi

# Update system packages
msg_info "Updating system packages..."
apt update && apt upgrade -y

# Install pnpm globally
msg_info "Installing or updating pnpm..."
npm install -g pnpm

msg_info "Installing ${APP} v${RELEASE}"

# Skip creating directories if existing installation
if [ ! -d "/opt/${APP}" ]; then
    # Create config directory for new installation
    msg_info "No existing install detected. Creating installation directory..."
    mkdir -p /opt/${APP}/config
    NEW_INSTALLATION=true
else
    msg_info "Existing install detected."
    NEW_INSTALLATION=false
fi

# Download and extract source
msg_info "Downloading source code..."
curl -fsSL "https://github.com/gethomepage/homepage/archive/refs/tags/${RELEASE}.tar.gz" -o "/tmp/${RELEASE}.tar.gz"
if [ $? -ne 0 ]; then
    msg_error "Failed to download source code"
    exit 1
fi

msg_info "Extracting source code..."
tar -xzf "/tmp/${RELEASE}.tar.gz" -C /tmp
if [ $? -ne 0 ]; then
    msg_error "Failed to extract source code"
    rm -f "/tmp/${RELEASE}.tar.gz"
    exit 1
fi

# Copy extracted files to installation directory
msg_info "Installing files..."
cp -r /tmp/${APP}-${RELEASE}/* /opt/${APP}/
if [ $? -ne 0 ]; then
    msg_error "Failed to move installation files"
    rm -rf /tmp/${APP}-${RELEASE}
    exit 1
fi

# Cleanup
rm -rf /tmp/${APP}-${RELEASE} /tmp/${RELEASE}.tar.gz

# New installations only
if [ "$NEW_INSTALLATION" = true ]; then
    # Copy skeleton files only for new installations
    if [ -d "/opt/${APP}/src/skeleton" ]; then
        msg_info "Copying skeleton files..."
        cp -r /opt/${APP}/src/skeleton/* /opt/${APP}/config/
    fi
    
    # Create environment file only for new installations
    msg_info "Creating environment file..."
    touch /opt/${APP}/.env
    echo "HOMEPAGE_ALLOWED_HOSTS=localhost:3000,${LOCAL_IP}:3000,homepage.home.jnbolsen.com:3000" >/opt/${APP}/.env
    
    # Create systemd service only for new installations
    msg_info "Creating systemd service..."
    cat <<EOF >/etc/systemd/system/${APP}.service
    [Unit]
    Description=${APP}  
    After=network.target
    StartLimitIntervalSec=0
    [Service]
    Type=simple
    Restart=always
    RestartSec=1
    User=root
    WorkingDirectory=/opt/${APP}/
    ExecStart=pnpm start
    [Install]
    WantedBy=multi-user.target
    EOF
fi

# Install dependencies and build
msg_info "Installing dependencies..."
cd /opt/${APP}
pnpm install

msg_info "Building application..."
pnpm build

# Create version file
echo "${RELEASE}" > $VERSION_FILE

msg_ok "Successfully installed ${APP} v${RELEASE}!"

# Reload systemd and enable service only for new installations, otherwise restart service
if [ "$NEW_INSTALLATION" = true ]; then
    msg_info "Enabling service..."
    systemctl daemon-reload
    systemctl enable ${APP}
    systemctl start ${APP}
    msg_ok "Service ${APP} started successfully!"
else
    msg_info "Restarting service..."
    systemctl restart ${APP}
    msg_ok "Service ${APP} started successfully!"
fi
