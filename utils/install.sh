#!/bin/bash

is_installed() {
    if dpkg -l "$1" 2>/dev/null | grep -q "^ii"; then
        return 0
    elif snap list "$1" &>/dev/null; then
        return 0
    elif cargo install --list 2>/dev/null | grep "^$1" &>/dev/null; then
        return 0
    elif npm list -g --depth=0 2>/dev/null | grep "$1@" &>/dev/null; then
        return 0
    elif [ "$1" = "nodejs" ] && command -v node >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

install_with_apt() {
    sudo apt install -y "$1"
}

install_with_snap() {
    case "$2" in
        classic)
            sudo snap install "$1" --classic
            ;;
        edge)
            sudo snap install "$1" --edge
            ;;
    esac
}

install_with_cargo() {
    cargo install "$1"
}

install_with_npm() {
    npm install -g "$1"
}

custom_install() {
    case "$1" in
        docker-ce)
            docker_pre_install
            ;;
        google-chrome-stable)
            chrome_install
            ;;
        nodejs)
            nodejs_install
            ;;
        zsh)
            zsh_install
            ;;
        rustup)
            rust_install
            ;;
        copyq)
            copyq_install
            ;;
        fonts-firacode)
            firacode_install
            ;;
    esac
}

docker_pre_install() {
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update -y

    sudo usermod -aG docker $USER
    newgrp docker
}

chrome_install() {
    wget https://dl-ssl.google.com/linux/linux_signing_key.pub -O /tmp/google.pub
    gpg --no-default-keyring --keyring /etc/apt/keyrings/google-chrome.gpg --import /tmp/google.pub
    echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update -y
    sudo apt install -y google-chrome-stable
}

nodejs_install() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    source ~/.bashrc
    nvm install 20
}

zsh_install() {
    sudo apt install -y zsh

    echo "Setting GNOME Terminal to use Zsh..."

    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/Terminal/Legacy/Profiles:/:$PROFILE_ID/" use-custom-command true
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/Terminal/Legacy/Profiles:/:$PROFILE_ID/" custom-command 'zsh'
}

rust_install() {
    sudo snap install rustup --classic
    rustup default stable
}

copyq_install() {
    sudo add-apt-repository -y ppa:hluk/copyq
    sudo apt update -y
    sudo apt install -y copyq
}

firacode_install() {
    sudo apt install -y fonts-firacode
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip"
    FONT_DIR="$HOME/.local/share/fonts"

    mkdir -p "$FONT_DIR"

    wget "$FONT_URL" -O "$FONT_NAME.zip"
    unzip "$FONT_NAME.zip" -d "$FONT_DIR"

    mv "$FONT_NAME"/* "$FONT_DIR/"

    fc-cache -fv

    # Set the font in GNOME Terminal
    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/Terminal/Legacy/Profiles:/:$PROFILE/" font "Fira Code Nerd Font"
}
