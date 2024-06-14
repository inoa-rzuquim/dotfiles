#!/bin/bash


SECRETS_DIR="/etc/secrets/"
if [ ! -d $SECRETS_DIR ]; then
  sudo mkdir $SECRETS_DIR
fi


echo -e "${VIOLET}* INOA VPN connections${NC}"
echo
read -p "Apply default config? [Y/n] " response
response=${response:-Y}
if [[ $response =~ ^[Yy]$ ]]; then
    VPN_PWD_FILE=/etc/secrets/vpn-pwd
    if [ ! -f $VPN_PWD_FILE ]; then
        read -p "Please enter your VPN password: " INOA_VPN_PASSWORD
        echo "$INOA_EMAIL" > $VPN_PWD_FILE
        echo "$INOA_VPN_PASSWORD" >> $VPN_PWD_FILE


    fi
    sudo openvpn --config ~/.inoa/security/inoa-svn-only.ovpn --auth-user-pass /etc/secrets/vpn-pwd
else
    echo -e "${RED}Won't apply vpn configuration!${NC}"
fi

