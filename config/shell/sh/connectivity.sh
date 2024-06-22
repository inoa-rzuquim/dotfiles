#!/bin/bash

function inoa-vpn() {
    if curl -s --head --request GET https://nexus.inoa.com.br/ --max-time 2 | grep "200" &>/dev/null; then
        echo "Already connected into inoa-vpn"
        return 0
    else
        sudo openvpn --config /etc/secrets/inoa-vpn.ovpn --auth-user-pass /etc/secrets/vpn-pwd --daemon
    fi
}

function inoa-svn-download-file() {
    SVN_CREDENTIALS_FILE=/etc/secrets/svn-pwd
    if [ ! -f $SVN_CREDENTIALS_FILE ]; then
        echo "Could not find credentials file"
        exit 1
    fi

    INOA_SVN_USER=$(sudo head -n 1 $SVN_CREDENTIALS_FILE)
    INOA_SVN_PWD=$(sudo tail -n 1 $SVN_CREDENTIALS_FILE)

    # sudo svn export --username $INOA_SVN_USER --password $INOA_SVN_PWD --non-interactive "$1" "$2"
    sudo curl -u "$INOA_SVN_USER":"$INOA_SVN_PWD" -o "$2" "$1"
}

