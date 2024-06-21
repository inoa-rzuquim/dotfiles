#!/bin/bash

set_shortcuts() {
    # Disable the default Print Screen shortcut
    gsettings set org.gnome.shell.keybindings show-screenshot-ui '[]'
    gsettings set org.gnome.shell.keybindings screenshot-window '[]'
    gsettings set org.gnome.shell.keybindings screenshot '[]'

    base_gsettings="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
    base_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
    custom_shortcuts=(
        "PrintScreen Interactive;flameshot gui;Print"
        "PrintScreen into file;flameshot full --path $HOME/Pictures/Screenshots/;<Shift>Print"
        "PrintScreen into clipboard;flameshot full --clipboard;<Ctrl>Print"
    )

    # Loop through the custom shortcuts and add them
    new_bindings="["
    for index in "${!custom_shortcuts[@]}"; do
        IFS=';' read -r name command binding <<< "${custom_shortcuts[index]}"
        new_bindings+="'$base_path/custom$index/', "
    done

    # Remove the trailing comma and space, and close the list
    new_bindings="${new_bindings%, }]"

    echo "adding new bindings $new_bindings"
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$new_bindings"

    for index in "${!custom_shortcuts[@]}"; do
        IFS=';' read -r name command binding <<< "${custom_shortcuts[index]}"
        add_custom_shortcut "$name" "$command" "$binding" "$index"
    done
}

add_custom_shortcut() {
    local name="$1"
    local command="$2"
    local binding="$3"
    local index="$4"

    local custom_keybinding_path="$base_path/custom$index/"

    echo "Setting shortcut [$index] $binding to $command $base_gsettings:$custom_keybinding_path"

    # Add the custom shortcut
    gsettings set $base_gsettings:$custom_keybinding_path name "$name"
    gsettings set $base_gsettings:$custom_keybinding_path command "$command"
    gsettings set $base_gsettings:$custom_keybinding_path binding "$binding"
}

