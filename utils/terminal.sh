#!/bin/bash

set_default_terminal() {
    set_terminal=$1
    terminal_name="${set_terminal##*/}"
    current_terminal=$(update-alternatives --query x-terminal-emulator | grep 'Value:' | awk '{print $2}')

    if [ "$set_terminal" != "$current_terminal" ]; then
        echo "Setting Alacritty as the default terminal emulator ($set_terminal)..."
        sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $set_terminal 50
        sudo update-alternatives --config x-terminal-emulator

        gsettings set org.gnome.desktop.default-applications.terminal exec "$terminal_name"
        gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''

        bin_link="/usr/local/bin/$terminal_name"
        if [ ! -L "$bin_link" ]; then
            sudo ln -s "$set_terminal" "$bin_link" > /dev/null
        fi
    else
        echo "Alacritty is already the default terminal emulator."
    fi
}

set_default_shell() {
    zsh_path=$1
    current_shell=$(getent passwd $USER | awk -F: '{print $7}')

    if [ "$current_shell" != "$zsh_path" ]; then
        echo "Setting Zsh as the default shell ($zsh_path)..."
        if [ ! -L ~/.zshrc ]; then
            ln -s ~/.config/shell/zshrc ~/.zshrc > /dev/null
        fi

        # suggestions 
        if [ ! -d  ~/.zsh/autosuggestions ]; then
            git clone git@github.com:zsh-users/zsh-autosuggestions.git ~/.zsh/autosuggestions
        fi
        if [ ! -d  ~/.zsh/completions ]; then
            git clone git@github.com:zsh-users/zsh-completions.git ~/.zsh/completions
        fi
        if [ ! -d  ~/.zsh/history-substring-search ]; then
            git clone git@github.com:zsh-users/zsh-history-substring-search.git ~/.zsh/history-substring-search
        fi

        echo "Please enter your user's password"
        chsh -s $zsh_path
    else
        echo "Zsh is already the default shell."
    fi
}

set_git_config() {
    mkdir -p ~/inoa/dev/
    if [ ! -L ~/.gitconfig ]; then
        echo "Setting up git..."
        ln -s ~/.config/git/gitconfig.toml ~/.gitconfig > /dev/null
    else
        echo "Git already configured"
    fi

    GIT_WHO_AM_I=~/.config/git/whoami.toml
    if [ ! -f $GIT_WHO_AM_I  ]; then
        echo "Setting up git whoami..."
        echo '[user]' > $GIT_WHO_AM_I
        echo "email = $INOA_EMAIL" >> $GIT_WHO_AM_I
        echo "email = $INO_NAME" >> $GIT_WHO_AM_I
    else
        echo "Git whoiam already configured"
    fi
}
