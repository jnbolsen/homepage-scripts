#!/bin/bash

set -e
set -u
set -o pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging functions
msg_info() { echo -e "${YELLOW}INFO:${NC} $1"; }
msg_ok() { echo -e "${GREEN}SUCCESS:${NC} $1"; }
msg_error() { echo -e "${RED}ERROR:${NC} $1" >&2; }

# Variables
APP=$(hostname)
LOCAL_IP=$(hostname -I | awk '{print $1}')
RELEASE=$(curl -fsSL "https://api.github.com/repos/gethomepage/homepage/releases/latest" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4 | sed 's/^v//')
VERSION_FILE="/opt/${APP}_version.txt"
DOMAIN=$(hostname -d 2>/dev/null || echo "")

# Validate
[ -z $APP ] && msg_error "Could not fetch hostname." && exit 1
[ -z $RELEASE ] && msg_error "Could not fetch release version." && exit 1
[ -z $LOCAL_IP ] && msg_error "Could not determine local IP address." && exit 1

# Check if already installed
if [ -f $VERSION_FILE ]; then
    INSTALLED_VERSION=$(cat $VERSION_FILE)
    if [ $INSTALLED_VERSION = $RELEASE ]; then
        msg_ok "Homepage is already at the latest version (v$RELEASE)."
        exit 0
    fi
    NEW_INSTALLATION=false
    msg_ok "A new version of Homepage is available (v$INSTALLED_VERSION)..."
    systemctl stop homepage
else
    NEW_INSTALLATION=true
    msg_ok "New installation detected..."
fi

# Update system and install pnpm
apt update && apt upgrade -y
npm install -g pnpm

# Download and extract source
msg_ok "Downloading and extracting source..."
curl -fsSL "https://github.com/gethomepage/homepage/archive/refs/tags/v${RELEASE}.tar.gz" -o "/tmp/${RELEASE}.tar.gz"
tar -xzf /tmp/${RELEASE}.tar.gz -C /tmp

# Copy source to installation folder and clean /tmp
msg_ok "Copying source to installation directory and cleaning up..."
cp -r /tmp/${APP}-${RELEASE}/* /opt/${APP}/
rm -r /tmp/${APP}-${RELEASE} /tmp/${RELEASE}.tar.gz

# Copy config files for new installations only
if [ $NEW_INSTALLATION = true ]; then
    msg_ok "Copying default configuration files..."
    [ -d /opt/${APP}/src/skeleton ] && cp -r /opt/${APP}/src/skeleton/* /opt/${APP}/config/
    
    # Create environment file
    msg_ok "Creating environment variable file..."
    if [ -z "$DOMAIN" ]; then
        echo "HOMEPAGE_ALLOWED_HOSTS=localhost:3000,${LOCAL_IP}:3000" > /opt/${APP}/.env
    else
        echo "HOMEPAGE_ALLOWED_HOSTS=localhost:3000,${LOCAL_IP}:3000,${APP}.${DOMAIN}:3000" > /opt/${APP}/.env
    fi
    
    # Create systemd service
    msg_ok "Creating systemd service..."
    cat > /etc/systemd/system/${APP}.service <<EOF
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
if [ -z "$DOMAIN" ]; then
    msg_ok "Access it via localhost:3000 or ${LOCAL_IP}:3000."
else
    msg_ok "Access it via localhost:3000, ${LOCAL_IP}:3000, or ${APP}.${DOMAIN}:3000."
fi


# Service management
if [ $NEW_INSTALLATION = true ]; then
    systemctl daemon-reload
    systemctl enable ${APP}
    systemctl start ${APP}
    msg_ok "Service ${APP} started successfully!"
else
    systemctl start ${APP}
    msg_ok "Service ${APP} started successfully!"
fi
