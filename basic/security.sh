#!/bin/bash

SECRETS_DIR="/etc/secrets/"
if [ ! -d $SECRETS_DIR ]; then
  sudo mkdir $SECRETS_DIR
fi

read_password() {
  local prompt=$1
  read -s -p "$prompt" password
  echo "$password"
}

echo -e "${VIOLET}* INOA VPN connections${NC}"
echo
read -p "Setup VPN credentials? [Y/n] " response
response=${response:-Y}
if [[ $response =~ ^[Yy]$ ]]; then
    VPN_PWD_FILE=/etc/secrets/vpn-pwd
    if [ ! -f $VPN_PWD_FILE ]; then
        while true; do
            INOA_VPN_PASSWORD=$(read_password "Please enter your VPN password:")
            echo
            INOA_VPN_PASSWORD_REPEAT=$(read_password "Repeat the password: ")
            echo

            if [ "$INOA_VPN_PASSWORD" == "$INOA_VPN_PASSWORD_REPEAT" ]; then
                break
            else
                echo -e "${RED}Passwords do not match. Please try again.${NC}"
            fi
        done

        echo
        local_temp=./vpn-pwd
        echo "$INOA_EMAIL" > $local_temp
        echo "$INOA_VPN_PASSWORD" >> $local_temp

        sudo mv $local_temp $VPN_PWD_FILE
        sudo chmod 400 $VPN_PWD_FILE
        sudo chown root $VPN_PWD_FILE
    fi

    SVN_PWD_FILE=/etc/secrets/svn-pwd
    if [ ! -f $SVN_PWD_FILE ]; then
        while true; do
            INOA_SVN_PASSWORD=$(read_password "Please enter your SVN password:")
            echo
            INOA_SVN_PASSWOR_REPEAT=$(read_password "Repeat the password: ")
            echo

            if [ "$INOA_SVN_PASSWORD" == "$INOA_SVN_PASSWOR_REPEAT" ]; then
                break
            else
                echo -e "${RED}Passwords do not match. Please try again.${NC}"
            fi
        done

        echo
        local_temp=./svn-pwd
        user="${INOA_EMAIL%%@*}"
        echo "$user" > $local_temp
        echo "$INOA_SVN_PASSWORD" >> $local_temp

        sudo mv $local_temp $SVN_PWD_FILE
        sudo chmod 400 $SVN_PWD_FILE
        sudo chown root $SVN_PWD_FILE
    fi

    download_full_ovpn
else
    echo -e "${RED}Won't apply vpn configuration!${NC}"
fi

