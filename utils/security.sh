#!/bin/bash

# Define variables
SVN_OVPN_CONFIG="$HOME/.inoa/dotfiles/security/inoa-svn-only.ovpn"
SVN_URL="https://svn.inoa.com.br/documents/Production/_Common/VPN/inoa-vpn-g2-beta2.ovpn"
OVPN_FILES_SECRETS="/etc/secrets/inoa-vpn.ovpn"

download_full_ovpn() {
    if [[ -f "$OVPN_FILES_SECRETS" ]]; then
        echo "Vpn file already exists!"
        return
    fi

    # NOTE: making sure sudo privileges are granted before starting a background process
    sudo echo "Connecting to OpenVPN..."
    sudo openvpn --config $SVN_OVPN_CONFIG --auth-user-pass $VPN_PWD_FILE &>/dev/null &
    VPN_PID=$!
    echo "OpenVPN started with PID $VPN_PID"

    echo -n "Waiting for VPN to establish connection "
    fake_loading 20

    echo "Downloading file using SVN ($SVN_URL => $OVPN_FILES_SECRETS)..."
    inoa-svn-download-file "$SVN_URL" "$OVPN_FILES_SECRETS"
    sudo chmod 400 $OVPN_FILES_SECRETS
    sudo chown root $OVPN_FILES_SECRETS

    if [ $? -eq 0 ]; then
        echo "File downloaded successfully."
    else
        echo "Failed to download the file."
    fi

    echo "Disconnecting OpenVPN..."
    sudo kill -SIGTERM $VPN_PID
    echo "OpenVPN disconnected."

    if [ ! -f $OVPN_FILES_SECRETS ]; then
        echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
        echo -e "${RED}Could not download inoa-vpn.ovpn${NC}"
        echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
        exit 1
    fi
}

fake_loading() {
    local duration=$1
    local total_dots=15
    local interval=$(echo "$duration / $total_dots" | bc -l)

    for ((i = 0; i < total_dots; i++)); do
        echo -n "."
        sleep $interval
    done
    echo
}
