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
    # TODO: read secrets file so this can run without prompting the password

    # NOTE: making sure sudo privileges are granted before starting a background process
    sudo echo "Connecting to OpenVPN..."
    sudo openvpn --config $SVN_OVPN_CONFIG --auth-user-pass $VPN_PWD_FILE &>/dev/null &
    VPN_PID=$!
    echo "OpenVPN started with PID $VPN_PID"

    echo -n "Waiting for VPN to establish connection "
    fake_loading 30

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

    echo "Connecting to inoa-vpn using the COMPLETE ovpn"
    inoa-vpn
    fake_loading 30
    echo "VPN should be connected"
}

install_inoa_cli() {
    # TODO: read secrets file so this can run without prompting the password
    if dotnet nuget list source | grep "Inoa" &>/dev/null; then
        echo "Inoa nuget source already configured"
    else
        dotnet nuget add source "https://inoanugetgallery.azurewebsites.net/api/v2" \
            --name "Inoa" --username "$user" --password "$INOA_NUGET_PASSWORD" --store-password-in-clear-text
    fi

    if inoa --version &>/dev/null; then
        echo "Inoa Cli already installed"
    else
        dotnet tool install --global Inoa.Cli
    fi
}

setup_npm() {
    # TODO: read secrets file so this can run without prompting the password
    if cat ~/.npmrc | grep @inoa:registry &> /dev/null; then
        echo "npmrc already contains inoa@nexus registy"
    else
        npm config set @inoa:registry=https://nexus.inoa.com.br/repository/npm-hosted/
    fi
    if cat ~/.npmrc | grep _authToken &> /dev/null; then
        echo "npmrc already contains inoa@nexus authToken"
    else
        # TODO: read configuration from already prompted credentials
        #       tried this methods without success (not the npm tool):
        #       https://stackoverflow.com/questions/54540096/give-credentials-to-npm-login-command-line
        npm login --registry https://nexus.inoa.com.br/repository/npm-hosted/
    fi
}

fake_loading() {
    local duration=$1
    local total_dots=15
    local interval=$(echo "$duration / $total_dots" | bc -l)

    for ((i = 0; i < total_dots; i++)); do
        echo -n "."
        if curl -s --head --request GET https://nexus.inoa.com.br/ --max-time 2 | grep "200" &>/dev/null; then
            return 0
        fi
        sleep $interval
    done
    echo
}
