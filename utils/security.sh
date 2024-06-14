#!/bin/bash

# Define variables
SVN_OVPN_CONFIG="~/.inoa/security/inoa-svn-only.ovpn"
SVN_URL="https://svn.inoa.com.br/documents/Production/_Common/VPN/inoa-vpn-g2-beta2.ovpn"
OVPN_FILES_SECRETS="/etc/secrets/inoa-vpn.ovpn"

download_full_ovpn() {
    connect_vpn
    download_complete_ovpn_file
    disconnect_vpn

    if [ ! -f $OVPN_FILES_SECRETS ]; then
        echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
        echo -e "${RED}Could not download inoa-vpn.ovpn${NC}"
        echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
        exit 1
    fi
}

connect_vpn() {
    echo "Connecting to OpenVPN..."
    sudo openvpn --config "$SVN_OVPN_CONFIG" --auth-user-pass $VPN_PWD_FILE &
    VPN_PID=$!
    echo "OpenVPN started with PID $VPN_PID"
}

download_complete_ovpn_file() {
    echo "Waiting for VPN to establish connection..."
    sleep 10  # Adjust the sleep time if needed to ensure the VPN connection is established

    echo "Downloading file using SVN..."
    svn export "$SVN_URL" "$OVPN_FILES_SECRETS"

    if [ $? -eq 0 ]; then
        echo "File downloaded successfully."
    else
        echo "Failed to download the file."
    fi
}

disconnect_vpn() {
    echo "Disconnecting OpenVPN..."
    sudo kill -SIGTERM $VPN_PID
    echo "OpenVPN disconnected."
}

