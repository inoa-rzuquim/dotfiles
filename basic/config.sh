#!/bin/bash

echo "This may overwrite existing files in your home directory."
echo "We recommend you to add your personalized configs on ~/.config/shell/custom.sh"

echo -e "${VIOLET}* Shell configuration${NC}"
echo
read -p "Apply default config? [Y/n] " response
response=${response:-Y}
if [[ $response =~ ^[Yy]$ ]]; then
    rsync \
        --exclude ".git/" \
        --exclude ".DS_Store" \
        --ignore-existing \
        -avh --no-perms ./config/ $HOME/.config > /dev/null

    set_default_terminal "$HOME/.cargo/bin/alacritty"
    set_default_shell "/usr/bin/zsh"
    set_git_config
else
    echo -e "${RED}Won't apply shell configuration!${NC}"
fi

echo -e "${VIOLET}* Appearance${NC}"
echo
read -p "Apply default appearance? [Y/n] " response
response=${response:-Y}
if [[ $response =~ ^[Yy]$ ]]; then
    rsync \
        --exclude ".git/" \
        --exclude ".DS_Store" \
        --ignore-existing \
        -avh --no-perms ./gnome/ $HOME/.local > /dev/null

    set_inoa_bg
    setup_dock
else
    echo -e "${RED}Won't apply appearance configuration!${NC}"
fi

echo -e "${VIOLET}* Shortcuts${NC}"
echo
read -p "Apply default shortcuts? [Y/n] " response
response=${response:-Y}
if [[ $response =~ ^[Yy]$ ]]; then
    set_shortcuts
else
    echo -e "${RED}Won't apply shortcuts!${NC}"
fi

