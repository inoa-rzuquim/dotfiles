#!/bin/bash

if [ -z "$INOA_NAME" ] || [ -z "$INOA_EMAIL" ]; then
    WHOAMI_FILE=~/.inoa/whoami
    if [ ! -f "$WHOAMI_FILE" ]; then
        echo "Could not find out who you are! Please run the boostrap script!"
        exit 1
    else
        INOA_EMAIL=$(head -n 1 $WHOAMI_FILE)
        INOA_NAME=$(tail -n 1 $WHOAMI_FILE)
        echo "Wellcome back $INOA_NAME ($INOA_EMAIL)!"
    fi
fi

source "./utils/colors.sh"
source "./utils/install.sh"
source "./utils/terminal.sh"
source "./utils/appearance.sh"
source "./utils/security.sh"

for file in ~/.config/shell/sh/*.sh; do
    . "$file"
done

source "./basic/install.sh"
echo ""
echo ""
echo ""
source "./basic/config.sh"
echo ""
echo ""
echo ""
source "./basic/security.sh"
echo ""
echo ""
echo ""

read -p "Do you want to setup the dev env for: [bt/at] " response
case "$response" in
    bt)
        source "./dev/bt.sh"
        ;;
    at)
        source "./dev/at.sh"
        ;;
    *)
        echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
        echo -e "${RED}Unkown dev env profile $response!${NC}"
        echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
        ;;
esac

