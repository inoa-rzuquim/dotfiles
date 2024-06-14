#!/bin/bash

function inoa-vpn() {
    sudo openvpn --config /etc/secrets/inoa-vpn.ovpn --auth-user-pass /etc/secrets/vpn-pwd --daemon
}

function inoa-svn-download-file() {
    SVN_CREDENTIALS_FILE=/etc/secrets/svn-pwd
    if [ ! -f $SVN_CREDENTIALS_FILE ]; then
        echo "Could not find credentials file"
        exit 1
    fi

    INOA_SVN_USER=$(sudo head -n 1 $SVN_CREDENTIALS_FILE)
    INOA_SVN_PWD=$(sudo tail -n 1 $SVN_CREDENTIALS_FILE)

    echo "$INOA_SVN_USER @ $INOA_SVN_PWD : $1 $2"
    sudo svn export --username $INOA_SVN_USER --password $INOA_SVN_PWD --non-interactive "$1" "$2"
}

