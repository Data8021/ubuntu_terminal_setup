#!/bin/bash

# menu function
function choose_from_menu() {
  local prompt="$1" outvar="$2"
  shift
  shift
  local options=("$@") cur=0 count=${#options[@]} index=0
  local esc=$(echo -en "\e") # cache ESC as test doesn't allow esc codes
  printf "$prompt\n"
  while true; do
    # list all options (option list is zero-based)
    index=0
    for o in "${options[@]}"; do
      if [ "$index" == "$cur" ]; then
        echo -e " >\e[7m$o\e[0m" # mark & highlight the current option
      else
        echo "  $o"
      fi
      ((index++))
    done
    read -s -n3 key               # wait for user to key in arrows or ENTER
    if [[ $key == $esc[A ]]; then # up arrow
      ((cur--))
      ((cur < 0)) && ((cur = 0))
    elif [[ $key == $esc[B ]]; then # down arrow
      ((cur++))
      ((cur >= count)) && ((cur = count - 1))
    elif [[ $key == "" ]]; then # nothing, i.e the read delimiter - ENTER
      break
    fi
    echo -en "\e[${count}A" # go up to the beginning to re-render
  done
  # export the selection to the requested output variable
  printf -v $outvar "${options[$cur]}"
}

# Set color
BRed='\033[1;31m'
NC='\033[0m'

# User selects chipset
selections=(
  "x86_64"
  "arm64"
)
choose_from_menu "${BRed}Select chipset...${NC}" selected_choice "${selections[@]}"

# Start installation
echo -e "${BRed}updating and upgrading pacakges...${NC}"
sudo apt update
sudo apt upgrade -y

echo -e "${BRed}installing initial set of terminal packages...${NC}"
while read -r p; do sudo apt-get install -y $p; done < <(
  cat <<"EOF"
    wget
    curl
    nano
    neovim
    python3-neovim
    git
    zip
    unzip
    bzip2
    gzip
    python3
    nodejs
    lsof
    zsh
    tmux
    bat
    fzf
    ripgrep
    fd-find
    findutils
    eza
    tree
    htop
    fastfetch
    tldr
    fontconfig
EOF
)

echo -e "${BRed}fixing bat...${NC}"
if [[ ! -d ~/.local/bin ]]; then
  mkdir -p ~/.local/bin
fi

if [[ ! -L ~/.local/bin/bat ]]; then
  ln -s /usr/bin/batcat ~/.local/bin/bat
fi

echo -e "${BRed}installing nerd font...${NC}"
declare -a fonts=(
  #   BitstreamVeraSansMono
  #   CascadiaCode
  #   CodeNewRoman
  #   DroidSansMono
  #   FiraCode
  #   FiraMono
  #   Go-Mono
  #   Hack
  #   Hermit
  JetBrainsMono
  #   Meslo
  #   Noto
  #   Overpass
  #   ProggyClean
  #   RobotoMono
  #   SourceCodePro
  #   SpaceMono
  #   Ubuntu
  #   UbuntuMono
)

version=$(curl -s 'https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest' | jq -r '.name')
if [ -z "$version" ] || [ "$version" = "null" ]; then
  version="v3.3.0"
fi

fonts_dir="/usr/share/fonts"

if [[ ! -d "$fonts_dir" ]]; then
  sudo mkdir -p "$fonts_dir"
fi

mkdir tmp

for font in "${fonts[@]}"; do
  zip_file="${font}.zip"
  download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${zip_file}"
  wget "$download_url"
  unzip -o "$zip_file" -d ./tmp
done

find ./tmp -name 'Windows Compatible' -delete

sudo mv ./tmp/* "$fonts_dir"
rm -rf tmp
rm "$zip_file"

fc-cache -fv

echo -e "${BRed}installing lazygit...${NC}"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${selected_choice}.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
rm lazygit.tar.gz
rm lazygit

echo -e "${BRed}installing lazyvim...${NC}"
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

echo -e "${BRed}installing starship...${NC}"
curl -sS https://starship.rs/install.sh | sh

echo -e "${BRed}change default shell to zsh...${NC}"
sudo chsh -s $(which zsh) $USER

echo -e "${BRed}copying dotfiles...${NC}"
cp ubuntu_terminal_setup/.local/bin/* ~/.local/bin
cp ubuntu_terminal_setup/.config/starship.toml ~/.config
cp -r ubuntu_terminal_setup/.config/bat ~/.config
cp -r ubuntu_terminal_setup/.config/tmux ~/.config
cp -r ubuntu_terminal_setup/.config/zsh ~/.config
cp ubuntu_terminal_setup/.config/.zprofile ~/
cp -r ubuntu_terminal_setup/.config/lazygit ~/.config

rm ~/.config/nvim/lua/config/keymaps.lua
cp ubuntu_terminal_setup/.config/nvim/keymaps.lua ~/.config/nvim/lua/config
cp ubuntu_terminal_setup/.config/nvim/colors.lua ~/.config/nvim/lua/plugins

rm ~/.gitconfig
cp ubuntu_terminal_setup/.config/git/.gitconfig ~/

echo -e "${BRed}Build bat cache...${NC}"
bat cache --build

echo -e "${BRed}REBOOTING NOW...${NC}"
sleep 10
sudo reboot now
