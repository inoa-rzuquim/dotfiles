#!/bin/bash

# NOTE: some of those packages need to be installed in this order

BASIC_PACKAGES=(
    # tools
    "git @ apt"
    "subversion @ apt"
    "snapd @ apt"
    "rustup @ custom"
    "nodejs @ custom"
    "python3 @ apt"
    "dotnet-sdk-8.0 @ apt"
    "curl @ apt"
    "btop @ apt"
    "dos2unix @ apt"
    "google-chrome-stable @ custom"
    "build-essential @ apt"
    "ca-certificates @ apt"
    "flameshot @ apt"
    "obsidian @ snap"
    "p7zip-full @ apt"
    "p7zip-rar @ apt"
    "cmake @ apt"
    "pkg-config @ apt"
    "libfreetype6-dev @ apt"
    "libfontconfig1-dev @ apt"
    "libxcb-xfixes0-dev @ apt"
    "libxkbcommon-dev @ apt"
    "copyq @ custom"
    "zoom @ custom"

    # communications
    "easy-rsa @ apt"
    "openvpn @ apt"
    "remmina @ snap"
    "telegram-desktop @ snap"
    "teams-for-linux @ snap"

    # terminal
    "zsh @ custom"
    "starship @ cargo"
    "fonts-firacode @ custom"
    "gitui @ cargo"
    "alacritty @ cargo"
    "eza @ cargo"
    "ripgrep @ apt"
    "bat @ apt"
    "fd-find @ apt"
    "fzf @ apt"
    "tlrc @ cargo"
    "tree @ apt"
    "xclip @ apt"
    "git-delta @ cargo"

    # editors
    "neovim @ apt"
    "code @ snap"
    "rider @ snap"

    # devtools
    "docker-ce @ custom"
    "prettier @ npm"
)

echo
echo -e "${VIOLET}* Installing basic tools${NC}"
echo "We are going to install the following tools:"

for package in "${BASIC_PACKAGES[@]}"; do
    package_name=$(echo "$package" | cut -d '@' -f 1 | xargs)
    if is_installed "$package_name"; then
        echo -e "  - $package_name ${GREEN}(Already installed)${NC}"
    else
        echo -e "  - $package_name"
    fi
done

read -p "Install missing packages? [Y/n] " response
response=${response:-Y}

if [[ $response =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}OK! LET's GO!${NC}"
else
    echo -e "${RED}Aborting setup!!${NC}"
    echo -e "${RED}Comment out what you don't want and run the script later.${NC}"
    return
fi

sudo apt update -y
sudo apt upgrade

for package in "${BASIC_PACKAGES[@]}"; do
    package_name=$(echo "$package" | cut -d '@' -f 1 | xargs)

    if is_installed "$package_name"; then 
        continue
    fi

    custom_install "$package_name" 

    package_manager=$(echo "$package" | cut -d '@' -f 2 | xargs)

    echo "Installing $package_name with $package_manager..."
    case "$package_manager" in
        apt)
            install_with_apt "$package_name"
            ;;
        snap)
            install_with_snap "$package_name" "classic"
            ;;
        snap-edge)
            install_with_snap "$package_name" "edge"
            ;;
        cargo)
            install_with_cargo "$package_name"
            ;;
        npm)
            install_with_npm "$package_name"
            ;;
        custom)
            ;;
        *)
            echo "Unknown package manager '$package_manager' for '$package_name'."
            ;;
    esac
done
