#!/bin/bash

# DOTFILES_REPO=git@github.com:inoa/dotfiles.git
DOTFILES_REPO=git@github.com:inoa-rzuquim/dotfiles.git
GIST_REPO=https://inoa.com.br/dev_boostrap.sh

# ---------------------------------
# COLORS
# ---------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN="\e[38;2;173;216;230m"
INDIGO="\e[38;2;75;0;130m"
VIOLET="\e[38;2;238;130;238m"
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ ! -t 0 ]; then
    echo "Please run this script interactively."
    echo ". <(curl -sL $GIST_REPO)"
    exit 1
fi

echo -e "${CYAN}                @@${NC}" 
echo -e "${CYAN}                @@@${NC}" 
echo -e "${CYAN}                @@@${NC}" 
echo -e "${CYAN}                @@@@${NC}" 
echo -e "${CYAN}       @@@      @@@@${NC}" 
echo -e "${CYAN}        @@@     @@@@${NC}" 
echo -e "${CYAN}         @@@    @@@@${NC}" 
echo -e "${CYAN}         @@@@   @@@@${NC}" 
echo -e "${CYAN}          @@@@  @@@@${NC}" 
echo -e "${CYAN}   @@@@@    @@@@ @@@@${NC}      !                     @@@" 
echo -e "${CYAN}      @@@@  @@@@ @@@@${NC}      !  @@ @@@      @@   @@@  @@@@      @@@" 
echo -e "${CYAN}        @@@@  @@@ @@@${NC}      !  @@ @@ @@    @@  @@       @@    @ @@" 
echo -e "${CYAN}          @@@@ @@@ @@${NC}      !  @@ @@  @@   @@ @@         @@  @@  @@" 
echo -e "${CYAN}   @@@@@@   @@@@${NC}           !  @@ @@   @@  @@ @@         @@ @@    @@" 
echo -e "${CYAN}    @@@@@@@@@@@@       @${NC}   !  @@ @@    @@ @@ @@         @@ @      @" 
echo -e "${CYAN}          @@@@@@    @@${NC}     !  @@ @@     @@@@ @@@       @@ @@      @@" 
echo -e "${CYAN}      @@@@@@@@@@@   @@@${NC}    !  @@ @@      @@@   @@     @@ @@        @@" 
echo -e "${CYAN}    @@@@@@@  @@@@@@@@@ @@${NC}  !  @@ @@       @@    @@@@@@@  @          @" 
echo -e "${CYAN}          @@@@ @@ @ @ @@${NC}" 
echo -e "${CYAN}        @@   @@ @@ @${NC}" 
echo -e "${CYAN}            @@  @   @${NC}" 
echo -e "${CYAN}            @${NC}" 

echo "Bootstraping dev env"
read -p "Please enter your inoa email: " INOA_EMAIL
echo

# ---------------------------------
# KNOWN HOSTS
# ---------------------------------
KNOWN_HOSTS_FILE=~/.ssh/known_hosts

if [ ! -d ~/.ssh ]; then
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
fi

# Check if github.com is already in known_hosts
if [ ! -f "$KNOWN_HOSTS_FILE" ] || ! grep -q "^github.com " "$KNOWN_HOSTS_FILE"; then
  echo -e "${CYAN}Adding github.com to known_hosts${NC}"
  ssh-keyscan github.com >> "$KNOWN_HOSTS_FILE"
fi

# ---------------------------------
# CLONING dotfiles
# ---------------------------------
CLONE_SUCCESSFUL=false

mkdir -p ~/.inoa/
cd ~/.inoa/

while [ "$CLONE_SUCCESSFUL" == false ]; do
    echo "Trying to clone $DOTFILES_REPO"
    git clone $DOTFILES_REPO

    if [ $? -eq 0 ]; then
        break
    fi

    echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
    echo -e "${RED}Could not clone dotfiles repository!${NC}"
    echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"

    # Check if an SSH key already exists
    if [ ! -f ~/.ssh/id_ed25519 ]; then
        echo -e "${CYAN}No SSH key found. Generating a new SSH key...${NC}"
        ssh-keygen -t ed25519 -C "$INOA_EMAIL" -f ~/.ssh/id_ed25519
        echo -e "${GREEN}SSH key generated and added to the ssh-agent.${NC}"
        echo
    fi

    echo -e "${YELLOW}Copy your public key to your GitHub account:${NC}"
    echo -e "${YELLOW}https://github.com/settings/ssh/new${NC}"
    echo
    while IFS= read -r line; do
        echo -e "${RED}$line${NC}"
    done < "$HOME/.ssh/id_ed25519.pub"
    echo
    read -n 1 -s -r -p "After adding the key on GitHub, press any key to try again..."
done

cd dotfiles
source ./init.sh

