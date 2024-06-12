
echo "This may overwrite existing files in your home directory."
echo "We recommend you to add your personalized configs on ~/.config/shell/custom.sh"
read -p "Apply default inoa config? (y/N) " -n 1
echo ""

# ==================
echo -n "🖥️ Shell ... "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rsync \
    --exclude ".git/" \
    --exclude ".DS_Store" \
    -avh --no-perms ./config/ $HOME/.config > /dev/null
  pushd ./common > /dev/null
  popd > /dev/null

  if [ ! -L "~/.zshrc" ]; then
    ln -s ~/.config/shell/zshrc ~/.zshrc > /dev/null
  fi

  # alacritty as the default terminal
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator ~/.cargo/bin/alacritty alacritty) 50
  sudo update-alternatives --config x-terminal-emulator
fi
echo "✔️"

