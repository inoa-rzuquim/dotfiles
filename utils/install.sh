
is_installed() {
    if dpkg -l "$1" 2>/dev/null | grep -q ^ii; then
        return 0
    elif snap list "$1" &> /dev/null; then
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
        google-chrome)
            chrome_install
            ;;
        nodejs)
            chrome_install
            ;;
        zsh)
            chrome_install
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

    sudo apt-get update

    sudo usermod -aG docker $USER
    newgrp docker
}

chrome_install() {
    wget https://dl-ssl.google.com/linux/linux_signing_key.pub -O /tmp/google.pub
    gpg --no-default-keyring --keyring /etc/apt/keyrings/google-chrome.gpg --import /tmp/google.pub
    echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt-get update 
    sudo apt-get install google-chrome-stable
}

nodejs_install() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    nvm install 20
}

zsh_install() {
    sudo apt install zsh
    echo 'deb http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-autosuggestions/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/shells:zsh-users:zsh-autosuggestions.list
    curl -fsSL https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_zsh-users_zsh-autosuggestions.gpg > /dev/null
    sudo apt update
    sudo apt install zsh-autosuggestions
}

